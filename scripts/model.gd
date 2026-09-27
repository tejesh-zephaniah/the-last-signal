
extends Node


func _ready():
	var file := FileAccess.open("user://model_hierarchy.txt", FileAccess.WRITE)

	if file:
		write_hierarchy(self, file)
		file.close()
		print("Hierarchy saved to: ", ProjectSettings.globalize_path("user://model_hierarchy.txt"))


func write_hierarchy(node: Node, file: FileAccess, indent: int = 0):
	var scene_status := "Scene" if node.scene_file_path != "" else "Node"

	file.store_line(
		"  ".repeat(indent)
		+ node.name
		+ " ("
		+ node.get_class()
		+ ") ["
		+ scene_status
		+ "]"
	)

	for child in node.get_children():
		write_hierarchy(child, file, indent + 1)
