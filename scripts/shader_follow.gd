extends MeshInstance3D

func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_3d()
	position = Vector3(cam.position.x, cam.position.y, cam.position.z - 0.75)
