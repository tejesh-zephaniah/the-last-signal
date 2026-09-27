extends Control


@onready var text_label: Label = $Panel/Text


func _ready():

	text_label.text = "GAME STATE DEBUG\n\n"


func _process(_delta):

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:
		text_label.text = "GAME STATE DEBUG\n\nGAMESTATE NOT FOUND"
		return


	text_label.text = """
GAME STATE DEBUG

PLAYER
Radio collected: %s
Laptop checked: %s
Beacon activated: %s


DOORS
Quarters opened: %s
Quarters closed: %s

Control opened: %s
Control closed: %s

Generator opened: %s
Generator closed: %s

Beacon opened: %s
Beacon closed: %s


GENERATOR / POWER
Generator started: %s
Generator ON: %s
Power ON: %s


CONTROL ROOM
CCTV used: %s
Controller used: %s
Emergency button: %s


BEACON
Console used: %s
""" % [

		game_state.radio_collected,
		game_state.laptop_checked,
		game_state.beacon_activated,

		game_state.quarters_door_opened,
		game_state.quarters_door_closed,

		game_state.control_door_opened,
		game_state.control_door_closed,

		game_state.generator_door_opened,
		game_state.generator_door_closed,

		game_state.beacon_door_opened,
		game_state.beacon_door_closed,

		game_state.generator_started,
		game_state.generator_on,
		game_state.power_on,

		game_state.cctv_used,
		game_state.controller_used,
		game_state.emergency_button_used,

		game_state.beacon_console_used
	]
