extends Area3D


var triggered: bool = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	# If power has already been restored, don't play
	# the initial powerless Control Room message.
	if game_state != null and game_state.power_on:
		return

	var radio_message = get_tree().current_scene.get_node_or_null(
		"InteractionUI/RadioMessage"
	)

	if radio_message != null:
		radio_message.show_message([
			"Control center has no power.",
			"Try restoring power using the generator."
		])

	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)

	if game_text != null:
		game_text.show_text(
			"OBJECTIVE: RESTORE POWER",
			5.0
		)
