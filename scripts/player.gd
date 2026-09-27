extends CharacterBody3D


@export var speed: float = 4.5
@export var mouse_sensitivity: float = 0.0025

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_prompt: Label = $"../InteractionUI/InteractionPrompt"
@onready var cctv_system = $"../CCTVSystem"
@onready var steps: AudioStreamPlayer = get_node_or_null("Steps")
@onready var fade: ColorRect = $"../InteractionUI/ColorRect"

var held_radio = null


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interaction_prompt.visible = false

	if fade != null:
		fade.visible = true
		fade.color = Color(0.0, 0.0, 0.0, 1.0)

		var tween := create_tween()
		tween.tween_property(
			fade,
			"color:a",
			0.0,
			2.0
		)

		await tween.finished

		fade.visible = false


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-85.0),
			deg_to_rad(85.0)
		)

	elif event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(_delta):
	var input_dir := Input.get_vector(
		"left",
		"right",
		"forward",
		"backward"
	)

	var direction := Vector3(
		input_dir.x,
		0.0,
		input_dir.y
	)

	direction = transform.basis * direction
	direction.y = 0.0
	direction = direction.normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if steps != null and not steps.playing:
			steps.play()

	else:
		velocity.x = 0.0
		velocity.z = 0.0

		if steps != null and steps.playing:
			steps.stop()

	velocity.y = 0.0
	move_and_slide()


func _process(_delta):
	update_interaction_prompt()

	if Input.is_action_just_pressed("interact"):
		if cctv_system != null and cctv_system.cctv_active:
			var object = get_interactable()

			# If we are still looking at the CCTV monitor,
			# let the CCTV system handle the E press.
			if object == $"../model/monitor2":
				return

			# We are looking at another interactable.
			# Close CCTV and interact with that object.
			cctv_system.close_cctv()

			if object != null:
				object.interact()

				# If this object is the radio and it was successfully picked up,
				# remember it permanently.
				if object.has_method("is_radio_held"):
					if object.is_radio_held():
						held_radio = object

			return

		try_interact()


func get_interactable():
	var from := camera.global_position
	var to := from + (-camera.global_transform.basis.z * 3.0)

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	var object = result["collider"]

	while object != null:
		if object.has_method("interact"):
			return object

		object = object.get_parent()

	return null


func update_interaction_prompt():
	var object = get_interactable()

	if object == null:
		interaction_prompt.visible = false
		return

	interaction_prompt.visible = true

	if object.has_method("get_interaction_text"):
		interaction_prompt.text = "[E]  " + object.get_interaction_text()
	else:
		interaction_prompt.text = "[E]  INTERACT"


func try_interact():
	var object = get_interactable()

	if object == null:
		return

	object.interact()

	# If this object is the radio and it was successfully picked up,
	# remember it permanently.
	if object.has_method("is_radio_held"):
		if object.is_radio_held():
			held_radio = object
