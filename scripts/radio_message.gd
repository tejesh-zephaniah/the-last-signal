extends Control


@export var typing_speed: float = 0.025
@export var line_duration: float = 3.0
@export var pause_between_lines: float = 0.1


@onready var message_panel: Panel = $MessagePanel
@onready var message_text: Label = $MessagePanel/MessageText
@onready var radio_static: AudioStreamPlayer = $RadioStatic


func _ready():

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_text.mouse_filter = Control.MOUSE_FILTER_IGNORE

	message_panel.visible = false


# ============================================================
# NORMAL RADIO MESSAGE
# ============================================================

func show_message(lines):

	message_panel.visible = true


	for line in lines:

		message_text.text = ""


		# Static plays while the message is being transmitted.
		radio_static.play()


		for i in line.length():

			message_text.text += line[i]

			await get_tree().create_timer(
				typing_speed
			).timeout


		# Transmission finished.
		radio_static.stop()


		# Keep completed message visible.
		await get_tree().create_timer(
			line_duration
		).timeout


		message_text.text = ""


		# Short pause.
		await get_tree().create_timer(
			pause_between_lines
		).timeout


	hide_message()


# ============================================================
# AI RADIO MESSAGE
# ============================================================

func show_ai_message(message: String):

	if message.is_empty():

		return


	message_panel.visible = true
	message_text.text = ""


	radio_static.play()


	for i in message.length():

		message_text.text += message[i]

		await get_tree().create_timer(
			typing_speed
		).timeout


	radio_static.stop()


	await get_tree().create_timer(
		line_duration
	).timeout


	hide_message()


# ============================================================
# HIDE
# ============================================================

func hide_message():

	radio_static.stop()

	message_panel.visible = false
