extends Node3D

@export var target : Node3D
@export var car : randymobile

func _process(delta: float) -> void:
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)
	global_rotation = Vector3(global_rotation.x, target.global_rotation.y, global_rotation.z)
	if car and car.riding:
		global_rotation = Vector3(-car.car_mesh.global_rotation.x, car.car_mesh.global_rotation.y, -car.car_mesh.global_rotation.z)
