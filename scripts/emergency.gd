extends Node3D


var activated: bool = false


@onready var alarm_sound: AudioStreamPlayer = $AlarmSound


func _ready():

	add_to_group("ai_alarm")


# ============================================================
# PLAYER INTERACTION
# ============================================================

func interact():

	if activated:

		stop_alarm()

		return


	trigger_alarm()


# ============================================================
# TRIGGER ALARM
# ============================================================

func trigger_alarm():

	if activated:
		return


	activated = true


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state != null:

		game_state.emergency_button_used = true
		game_state.alarm_active = true


	if alarm_sound != null:

		alarm_sound.play()


	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	if game_text != null:

		game_text.show_text(
			"EMERGENCY SYSTEM ACTIVATED",
			4.0
		)


	print(
		"ALARM: ACTIVATED"
	)


# ============================================================
# STOP ALARM
# ============================================================

func stop_alarm():

	if not activated:
		return


	activated = false


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state != null:

		game_state.emergency_button_used = false
		game_state.alarm_active = false


	if alarm_sound != null:

		alarm_sound.stop()


	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	if game_text != null:

		game_text.show_text(
			"EMERGENCY SYSTEM DEACTIVATED",
			4.0
		)


	print(
		"ALARM: STOPPED"
	)


# ============================================================
# INTERACTION TEXT
# ============================================================

func get_interaction_text() -> String:

	if activated:

		return "STOP ALARM"


	return "TRIGGER ALARM"
