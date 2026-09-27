extends Node3D


var animation_player: AnimationPlayer
var is_open: bool = false
var locked: bool = false

var ai_lock_timer: float = 0.0


func _ready():
	animation_player = find_child("AnimationPlayer", true, false)

	if animation_player == null:
		push_error("AnimationPlayer not found inside: " + name)

	add_to_group("ai_doors")


func _process(delta):
	if ai_lock_timer > 0.0:

		ai_lock_timer -= delta

		if ai_lock_timer <= 0.0:

			ai_lock_timer = 0.0
			unlock()


func interact():

	if animation_player == null:
		return


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	var game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)


	# ============================================================
	# AI LOCK
	# ============================================================

	if locked:

		if game_text != null:
			game_text.show_text(
				"DOOR LOCKED",
				2.0
			)

		return


	# ============================================================
	# QUARTERS DOOR
	# ============================================================

	if name == "Quaters_door":

		if game_state != null:

			if not game_state.radio_interaction_complete:

				if game_text != null:
					game_text.show_text(
						"INTERACT WITH THE RADIO FIRST",
						3.0
					)

				return


	# ============================================================
	# CONTROL ROOM DOOR
	# ============================================================

	if name == "Control_door":

		if game_state != null:

			if not game_state.radio_interaction_complete:

				if game_text != null:
					game_text.show_text(
						"INTERACT WITH THE RADIO FIRST",
						3.0
					)

				return


	# ============================================================
	# BEACON DOOR
	# ============================================================

	if name == "Beacon_door":

		if game_state != null:

			if not game_state.controller_used:

				if game_text != null:
					game_text.show_text(
						"BEACON CONTROL LOCKED",
						3.0
					)

				return


	# ============================================================
	# OPEN / CLOSE
	# ============================================================

	if is_open:
		close()
	else:
		open()


func get_interaction_text() -> String:

	if locked:
		return "LOCKED"

	if is_open:
		return "CLOSE"

	return "OPEN"


# ============================================================
# AI LOCK
# ============================================================

func lock(duration: float = 0.0):

	locked = true

	if is_open:
		close()

	if duration > 0.0:
		ai_lock_timer = duration

	update_game_state_lock(true)


func unlock():

	locked = false
	ai_lock_timer = 0.0

	update_game_state_lock(false)


# ============================================================
# UPDATE GAME STATE LOCK
# ============================================================

func update_game_state_lock(is_locked: bool):

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:
		return


	match name:

		"Quaters_door":
			game_state.quarters_door_locked = is_locked

		"Control_door":
			game_state.control_door_locked = is_locked

		"Generator_door":
			game_state.generator_door_locked = is_locked

		"Beacon_door":
			game_state.beacon_door_locked = is_locked


# ============================================================
# OPEN
# ============================================================

func open():

	if animation_player.has_animation("open"):

		animation_player.play("open")
		is_open = true


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:
		return


	# ============================================================
	# RECORD DOOR OPENING
	# ============================================================

	match name:

		"Quaters_door":
			game_state.quarters_door_opened = true

		"Control_door":
			game_state.control_door_opened = true

		"Generator_door":
			game_state.generator_door_opened = true

		"Beacon_door":
			game_state.beacon_door_opened = true


# ============================================================
# CLOSE
# ============================================================

func close():

	if animation_player.has_animation("close"):

		animation_player.play("close")
		is_open = false


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:
		return


	# ============================================================
	# RECORD DOOR CLOSING
	# ============================================================

	match name:

		"Quaters_door":
			game_state.quarters_door_closed = true

		"Control_door":
			game_state.control_door_closed = true

		"Generator_door":
			game_state.generator_door_closed = true

		"Beacon_door":
			game_state.beacon_door_closed = true
