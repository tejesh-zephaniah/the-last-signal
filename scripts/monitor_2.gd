extends Node3D


func interact():
	var cctv = get_tree().current_scene.get_node_or_null("CCTVSystem")

	if cctv == null:
		return

	cctv.open_cctv()


func get_interaction_text() -> String:
	return "VIEW CAMERAS"
