extends Camera3D

@export var lerp_speed = 3.0
@export var offset = Vector3.ZERO
@export var target : Node

var target_pos

var offset_angle: Vector3


func _physics_process(delta):
	if !target:
		return
	target_pos = target.global_transform.translated_local(offset)
	if target.get_parent().in_control:
		#if Input.is_action_pressed("look_right"):
			#rotate_y(-player_body.look_sensitivity_h)
		#if Input.is_action_pressed("look_left"):
			#rotate_y(player_body.look_sensitivity_h)
		if Input.is_action_pressed("look_up"):
			target_pos = target_pos.rotated_local(Vector3.LEFT, target.get_parent().player_body.look_sensitivity_v * 0.1)
		if Input.is_action_pressed("look_down"):
			target_pos = target_pos.rotated_local(Vector3.LEFT, -target.get_parent().player_body.look_sensitivity_v * 0.1)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_position, Vector3.UP)
