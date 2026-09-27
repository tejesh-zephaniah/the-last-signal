extends Node3D


@export var beacon_activate_sound: AudioStreamPlayer3D
@export var beacon_particles: GPUParticles3D


var activated: bool = false
var activation_in_progress: bool = false
var beacon_ai_transmission_played: bool = false


func _ready():

	add_to_group("ai_beacon")


# ============================================================
# PROCESS
# ============================================================

func _process(_delta):

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state == null:

		return


	# ========================================================
	# AUTOMATIC BEACON ROOM AI TRANSMISSION
	# ========================================================

	if game_state.player_room == "Beacon":

		if not beacon_ai_transmission_played:

			beacon_ai_transmission_played = true

			play_beacon_ai_transmission()


# ============================================================
# BEACON ROOM AI TRANSMISSION
# ============================================================

func play_beacon_ai_transmission():

	var radio_message = get_tree().current_scene.get_node_or_null(
		"InteractionUI/RadioMessage"
	)


	if radio_message == null:

		return


	await radio_message.show_ai_message(
		"Krrr— control lost... beacon access... accepted."
	)


	await radio_message.show_ai_message(
		"Signal terminating... s-sorry... no. I don't say sorry."
	)


	await radio_message.show_ai_message(
		"I predicted you would stop. You didn't. ...you win."
	)


# ============================================================
# PLAYER INTERACTION
# ============================================================

func interact():

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	if game_state == null:

		if game_text != null:

			game_text.show_text(
				"SYSTEM ERROR: GAME STATE UNAVAILABLE",
				4.0
			)

		return


	# ============================================================
	# ALREADY COMPLETED
	# ============================================================

	if activated:

		if game_text != null:

			game_text.show_text(
				"BEACON ALREADY ACTIVE",
				3.0
			)

		return


	# ============================================================
	# CHECK BEACON SYSTEM
	# ============================================================

	if not game_state.beacon_online:

		if game_text != null:

			game_text.show_text(
				"BEACON SYSTEM OFFLINE",
				4.0
			)

		return


	# ============================================================
	# ALREADY ACTIVATING
	# ============================================================

	if activation_in_progress:

		return


	activation_in_progress = true

	game_state.beacon_console_used = true


	# ============================================================
	# ACTIVATION SEQUENCE
	# ============================================================

	if game_text != null:

		await game_text.show_text(
			"BEACON ACTIVATION INITIATED",
			2.5
		)


	# ============================================================
	# AI INTERRUPTION CHECK
	# ============================================================

	if not activation_in_progress:
		return


	if not game_state.beacon_online:

		activation_interrupted()

		return


	if game_text != null:

		await game_text.show_text(
			"CALIBRATING BEACON...",
			2.5
		)


	# ============================================================
	# SECOND CHECK
	# ============================================================

	if not activation_in_progress:
		return


	if not game_state.beacon_online:

		activation_interrupted()

		return


	if game_text != null:

		await game_text.show_text(
			"CONTACTING CONTROL NETWORK...",
			3.0
		)


	# ============================================================
	# FINAL CHECK
	# ============================================================

	if not activation_in_progress:
		return


	if not game_state.beacon_online:

		activation_interrupted()

		return


	# ============================================================
	# SUCCESS
	# ============================================================

	activation_in_progress = false
	activated = true

	game_state.beacon_activated = true


	# ============================================================
	# BEACON ACTIVATION EFFECTS
	# ============================================================

	if beacon_activate_sound != null:

		beacon_activate_sound.play()


	if beacon_particles != null:

		beacon_particles.emitting = false
		beacon_particles.restart()
		beacon_particles.emitting = true


	if game_text != null:

		await game_text.show_text(
			"BEACON ACTIVATED",
			5.0
		)


	print(
		"BEACON: ACTIVATED"
	)


	# ============================================================
	# FINAL FADE TO BLACK
	# ============================================================

	await get_tree().create_timer(4.0).timeout

	fade_to_black()


# ============================================================
# FADE TO BLACK
# ============================================================

func fade_to_black():

	var fade = get_tree().current_scene.get_node_or_null(
		"InteractionUI/ColorRect"
	)


	if fade == null:

		return


	fade.visible = true
	fade.color = Color(
		0.0,
		0.0,
		0.0,
		0.0
	)


	var tween := create_tween()

	tween.tween_property(
		fade,
		"color:a",
		1.0,
		2.0
	)

	await tween.finished


	fade.color = Color(
		0.0,
		0.0,
		0.0,
		1.0
	)


# ============================================================
# AI INTERRUPTION
# ============================================================

func activation_interrupted():

	if not activation_in_progress:

		return


	activation_in_progress = false
	activated = false


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	if game_state != null:

		game_state.beacon_activated = false
		game_state.beacon_online = false


	if game_text != null:

		game_text.show_text(
			"BEACON ACTIVATION INTERRUPTED",
			4.0
		)


	print(
		"BEACON: ACTIVATION INTERRUPTED"
	)


# ============================================================
# INTERACTION TEXT
# ============================================================

func get_interaction_text() -> String:

	if activated:

		return "BEACON ACTIVE"


	if activation_in_progress:

		return "ACTIVATING..."


	return "ACTIVATE BEACON"
