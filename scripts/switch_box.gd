
extends Node3D


var animation_player: AnimationPlayer
var generator_on: bool = false

var omni_light: OmniLight3D
var spot_light: SpotLight3D

var game_state


const GENERATOR_ON_TIME := 7.01
const GENERATOR_END_TIME := 10.0

const LIGHT_FADE_TIME := 1.0
const SOUND_FADE_TIME := 1.5


@onready var generator_sound: AudioStreamPlayer3D = $GeneratorSound


func _ready():

	add_to_group("ai_generator")


	game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state == null:

		push_error(
			"GameState not found in current scene."
		)


	animation_player = find_child(
		"AnimationPlayer",
		true,
		false
	)


	if animation_player == null:

		push_error(
			"AnimationPlayer not found inside: " + name
		)


	omni_light = $RedLight/OmniLight3D
	spot_light = $RedLight/SpotLight3D


	# ============================================================
	# GENERATOR STARTS OFF
	# ============================================================

	if omni_light != null:

		omni_light.visible = false
		omni_light.light_energy = 0.0


	if spot_light != null:

		spot_light.visible = false
		spot_light.light_energy = 0.0


	if generator_sound != null:

		generator_sound.volume_db = -80.0


# ============================================================
# PLAYER INTERACTION
# ============================================================

func interact():

	if generator_on:

		shutdown_generator()

	else:

		start_generator()


# ============================================================
# START GENERATOR
# ============================================================

func start_generator():

	if generator_on:
		return


	if animation_player == null:
		return


	generator_on = true


	if game_state != null:

		game_state.generator_started = true
		game_state.generator_on = true
		game_state.power_on = true


	animation_player.play_section(
		"Animation",
		0.0,
		GENERATOR_ON_TIME
	)


	start_generator_effects()


	print(
		"GENERATOR: STARTED"
	)


# ============================================================
# SHUT DOWN GENERATOR
# ============================================================

func shutdown_generator():

	if not generator_on:
		return


	if animation_player == null:
		return


	generator_on = false


	if game_state != null:

		game_state.generator_on = false
		game_state.power_on = false


	animation_player.play_section(
		"Animation",
		GENERATOR_ON_TIME,
		GENERATOR_END_TIME
	)


	stop_generator_effects()


	print(
		"GENERATOR: SHUT DOWN"
	)


# ============================================================
# GENERATOR EFFECTS
# ============================================================

func start_generator_effects():

	if omni_light != null:

		omni_light.visible = true
	omni_light.light_energy = 0.0


	if spot_light != null:

		spot_light.visible = true
		spot_light.light_energy = 0.0


	var light_tween := create_tween().set_parallel(true)


	if omni_light != null:

		light_tween.tween_property(
			omni_light,
			"light_energy",
			1.0,
			LIGHT_FADE_TIME
		).set_trans(
			Tween.TRANS_SINE
		).set_ease(
			Tween.EASE_IN_OUT
		)


	if spot_light != null:

		light_tween.tween_property(
			spot_light,
			"light_energy",
			1.0,
			LIGHT_FADE_TIME
		).set_trans(
			Tween.TRANS_SINE
		).set_ease(
			Tween.EASE_IN_OUT
		)


	if generator_sound == null:
		return


	generator_sound.volume_db = -80.0

	generator_sound.play()


	var sound_tween := create_tween()


	sound_tween.tween_property(
		generator_sound,
		"volume_db",
		0.0,
		SOUND_FADE_TIME
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)


# ============================================================
# STOP GENERATOR EFFECTS
# ============================================================

func stop_generator_effects():

	var light_tween := create_tween().set_parallel(true)


	if omni_light != null:

		light_tween.tween_property(
			omni_light,
			"light_energy",
			0.0,
			LIGHT_FADE_TIME
		).set_trans(
			Tween.TRANS_SINE
		).set_ease(
			Tween.EASE_IN_OUT
		)


	if spot_light != null:

		light_tween.tween_property(
			spot_light,
			"light_energy",
			0.0,
			LIGHT_FADE_TIME
		).set_trans(
			Tween.TRANS_SINE
		).set_ease(
			Tween.EASE_IN_OUT
		)


	await light_tween.finished


	if omni_light != null:

		omni_light.visible = false


	if spot_light != null:

		spot_light.visible = false


	if generator_sound == null:
		return


	var sound_tween := create_tween()


	sound_tween.tween_property(
		generator_sound,
		"volume_db",
		-80.0,
		SOUND_FADE_TIME
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)


	await sound_tween.finished


	generator_sound.stop()


# ============================================================
# INTERACTION TEXT
# ============================================================

func get_interaction_text() -> String:

	if generator_on:

		return "SHUT DOWN GENERATOR"


	return "START GENERATOR"
