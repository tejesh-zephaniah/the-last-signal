extends Node3D


var is_held: bool = false

var player: CharacterBody3D
var hold_position: Marker3D
var radio_message


func _ready():
	player = get_tree().current_scene.get_node_or_null("player")

	if player == null:
		push_error("Radio: Could not find player at current_scene/player.")
		return

	hold_position = player.get_node_or_null(
		"Head/Camera3D/RadioHoldPosition"
	)

	if hold_position == null:
		push_error("Radio: RadioHoldPosition not found.")

	radio_message = get_tree().current_scene.get_node_or_null(
		"InteractionUI/RadioMessage"
	)

	if radio_message == null:
		push_error("Radio: RadioMessage UI not found.")


func interact():

	if is_held:
		return

	pick_up()


func get_interaction_text() -> String:

	if is_held:
		return ""

	return "PICK UP"


func pick_up():

	if is_held:
		return

	if hold_position == null:
		return

	is_held = true


	# ============================================================
	# MOVE RADIO TO PLAYER
	# ============================================================

	reparent(hold_position, true)

	position = Vector3.ZERO
	rotation = Vector3.ZERO

	set_collisions_enabled(false)


	# ============================================================
	# UPDATE GAME STATE
	# ============================================================

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state != null:
		game_state.radio_collected = true


	# ============================================================
	# RADIO MESSAGE
	# ============================================================

	if radio_message != null:

		await radio_message.show_message([
			"Emergency beacon is offline.",
			"You need to restore power.",
			"Then activate the emergency beacon."
		])


	# ============================================================
	# RADIO INTERACTION IS NOW FULLY COMPLETE
	# ============================================================

	if game_state != null:
		game_state.radio_interaction_complete = true


	# ============================================================
	# OBJECTIVE
	# ============================================================

	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)

	if game_text != null:

		game_text.show_text(
			"OBJECTIVE: Reach the Control Room",
			5.0
		)


func set_collisions_enabled(enabled: bool):

	var collision_nodes = find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	)

	for collision in collision_nodes:

		collision.set_deferred(
			"disabled",
			not enabled
		)


func is_radio_held() -> bool:

	return is_held
