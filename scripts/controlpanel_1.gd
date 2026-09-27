
extends Node3D


var accessed: bool = false


func interact():

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	if game_text == null:
		return


	if game_state == null:

		game_text.show_text(
			"SYSTEM ERROR: GAME STATE UNAVAILABLE",
			4.0
		)

		return


	accessed = true


	# ============================================================
	# DISPLAY CURRENT SYSTEM STATUS
	# ============================================================

	var power_status := "ONLINE"

	if not game_state.power_on:

		power_status = "OFFLINE"


	var cctv_status := "ONLINE"

	if not game_state.cctv_online:

		cctv_status = "OFFLINE"


	var radio_status := "ONLINE"

	if not game_state.radio_online:

		radio_status = "OFFLINE"


	var beacon_status := "OFFLINE"

	if game_state.beacon_activated:

		beacon_status = "ONLINE"


	var message := (
		"REMOTE STATION CONTROL\n"
		+ "POWER: " + power_status + "\n"
		+ "CCTV: " + cctv_status + "\n"
		+ "RADIO: " + radio_status + "\n"
		+ "BEACON: " + beacon_status
	)


	game_text.show_text(
		message,
		5.0
	)


func get_interaction_text() -> String:

	return "ACCESS SYSTEMS"
