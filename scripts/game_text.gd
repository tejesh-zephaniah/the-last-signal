extends Control


@onready var text_label: Label = $Text


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.visible = false


func show_text(message: String, duration: float = 3.0):
	text_label.text = message
	text_label.visible = true

	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

		text_label.visible = false


func show_persistent_text(message: String):
	text_label.text = message
	text_label.visible = true


func hide_text():
	text_label.visible = false
