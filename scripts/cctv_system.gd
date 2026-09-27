
extends Node3D


var cctv_active: bool = false
var current_camera_index: int = 0


@export var monitor_text_distance: float = 3.0


@onready var viewport: SubViewport = $SubViewport

@onready var cctv_camera: Camera3D = $SubViewport/Camera3D

@onready var player: CharacterBody3D = $"../player"


@onready var station_cameras = [
	$"../model/cam/Camera3D",
	$"../model/cam2/Camera3D",
	$"../model/cam3/Camera3D",
	$"../model/cam4/Camera3D",
	$"../model/cam5/Camera3D"
]


@onready var monitor_screen: MeshInstance3D = $"../model/monitor2/screen"

@onready var game_text: Control = $"../InteractionUI/GameText"


func _ready():

	setup_monitor()


# ============================================================
# PROCESS
# ============================================================

func _process(_delta):

	if not cctv_active:
		return


	var object = player.get_interactable()


	if object != null and object != $"../model/monitor2":

		close_cctv()

		return


	if player != null and monitor_screen != null:

		var distance := player.global_position.distance_to(
			monitor_screen.global_position
		)


		if distance > monitor_text_distance:

			close_cctv()

			return


	if Input.is_action_just_pressed("interact"):

		switch_camera(
			(current_camera_index + 1)
			% station_cameras.size()
		)


	elif Input.is_action_just_pressed("ui_cancel"):

		close_cctv()


# ============================================================
# OPEN CCTV
# ============================================================

func open_cctv():

	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state != null:

		if not game_state.cctv_online:

			if game_text != null:

				game_text.show_text(
					"CCTV SYSTEM OFFLINE",
					3.0
				)

			return


	cctv_active = true


	if game_state != null:

		game_state.cctv_used = true


	switch_camera(
		current_camera_index
	)


# ============================================================
# CLOSE CCTV
# ============================================================

func close_cctv():

	cctv_active = false


	if game_text != null:

		game_text.hide_text()


# ============================================================
# SWITCH CAMERA
# ============================================================

func switch_camera(index: int):

	if index < 0 or index >= station_cameras.size():

		return


	var game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)


	if game_state != null:

		if not game_state.cctv_online:

			return


	current_camera_index = index


	var station_camera = station_cameras[index]


	cctv_camera.global_transform = station_camera.global_transform

	cctv_camera.fov = station_camera.fov


	if cctv_active and game_text != null:

		var camera_names = [
			"CREW QUARTERS",
			"CONTROL ROOM",
			"GENERATOR ROOM",
			"CORRIDOR",
			"BEACON CONTROL"
		]


		game_text.show_persistent_text(
			"CAM %02d — %s"
			% [
				current_camera_index + 1,
				camera_names[current_camera_index]
			]
		)


# ============================================================
# UPDATE CAMERA
# ============================================================

func update_camera():

	switch_camera(
		current_camera_index
	)


# ============================================================
# SETUP MONITOR
# ============================================================

func setup_monitor():

	var material := StandardMaterial3D.new()


	material.albedo_texture = viewport.get_texture()


	monitor_screen.material_override = material
