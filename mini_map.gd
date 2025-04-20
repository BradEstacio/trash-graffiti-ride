extends ColorRect

@export var target : NodePath
@export var camera_distance := 20.0

@onready var player_body := get_node(target)
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D

func _process(delta: float) -> void:
	if target:
		camera.size = camera_distance
		camera.global_position = Vector3(player_body.global_position.x, camera_distance, player_body.global_position.z)
