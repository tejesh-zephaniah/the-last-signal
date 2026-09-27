
extends Node


func _ready():
	print_hierarchy(self)


func print_hierarchy(node: Node, indent: int = 0):
	var scene_status := "Scene" if node.scene_file_path != "" else "Node"

	print(
		"  ".repeat(indent)
		+ node.name
		+ " ("
		+ node.get_class()
		+ ") ["
		+ scene_status
		+ "]"
	)

	# Don't print the internal hierarchy of instanced scenes.
	if node != self and node.scene_file_path != "":
		return

	for child in node.get_children():
		print_hierarchy(child, indent + 1)
