extends Area3D


# ============================================================
# ROOM NAME
# ============================================================

@export var room_name: String = "Unknown"


# ============================================================
# GAME STATE
# ============================================================

var game_state


# ============================================================
# READY
# ============================================================

func _ready():

	game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:

		push_error(
			"Room Area: GameState not found for " + name
		)

		return


	body_entered.connect(_on_body_entered)


# ============================================================
# PLAYER ENTERED ROOM
# ============================================================

func _on_body_entered(body):

	if body.name != "player":
		return


	if game_state == null:
		return


	game_state.player_room = room_name


	print(
		"PLAYER ROOM: ",
		game_state.player_room
	)
