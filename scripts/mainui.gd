extends TextureRect


@export var main_game_scene: PackedScene


func _ready():

	$Play.pressed.connect(_on_play_pressed)
	$Exit.pressed.connect(_on_exit_pressed)


func _on_play_pressed():

	if main_game_scene != null:

		get_tree().change_scene_to_packed(main_game_scene)


func _on_exit_pressed():

	get_tree().quit()
