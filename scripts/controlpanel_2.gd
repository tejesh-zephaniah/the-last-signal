extends Node3D


var activated: bool = false


func interact():

	# ============================================================
	# GET GAME STATE
	# ============================================================

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
	# POWER CHECK
	# ============================================================

	if not game_state.power_on:

		if game_text != null:
			game_text.show_text(
				"POWER MUST BE RESTORED FIRST",
				4.0
			)

		return


	# ============================================================
	# ALREADY ACTIVATED
	# ============================================================

	if activated:
		return


	activated = true


	# ============================================================
	# RECORD INTERACTION
	# ============================================================

	game_state.controller_used = true


	# ============================================================
	# UNLOCK BEACON ACCESS
	# ============================================================

	if game_text != null:

		await game_text.show_text(
			"CONTROL SYSTEMS ONLINE",
			3.0
		)

		game_text.show_text(
			"BEACON CONTROL ACCESS UNLOCKED",
			5.0
		)


func get_interaction_text() -> String:

	if activated:
		return "SYSTEM ONLINE"

	return "ACCESS CONTROL SYSTEM"
