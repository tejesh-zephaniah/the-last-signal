extends Node3D


func interact():

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)

	if game_text == null:
		return


	# ============================================================
	# GAMESTATE CHECK
	# ============================================================

	if game_state == null:

		game_text.show_text(
			"SYSTEM ERROR: GAME STATE UNAVAILABLE",
			4.0
		)

		return


	# ============================================================
	# POWER OFF
	# ============================================================

	if not game_state.power_on:

		await game_text.show_text(
			"SYSTEM DIAGNOSTICS: POWER OFFLINE",
			4.0
		)

		return


	# ============================================================
	# POWER RESTORED
	# ============================================================

	game_state.laptop_checked = true

	# LAPTOP INTERACTION IS NOW COMPLETE
	game_state.laptop_interaction_complete = true


	# ============================================================
	# ACTIVATE BULB2 LIGHT
	# ============================================================

	var bulb_light = get_tree().current_scene.get_node_or_null(
		"model/Bulb2/OmniLight3D"
	)

	if bulb_light != null:
		bulb_light.visible = true


	# ============================================================
	# MESSAGE
	# ============================================================

	await game_text.show_text(
		"SYSTEM DIAGNOSTICS: POWER RESTORED",
		4.0
	)


	# ============================================================
	# NEXT OBJECTIVE
	# ============================================================

	game_text.show_text(
		"OBJECTIVE: PROCEED TO THE NEXT SYSTEM",
		5.0
	)


func get_interaction_text() -> String:

	return "CHECK SYSTEMS"
