extends RigidBody3D

var awaiting_input = false
var riding = false
var player_body
var in_control = false
var paused = false

var sphere_offset = Vector3.DOWN
@export var acceleration = 35.0
@export var steering = 19.0
@export var turn_speed = 4.0
@export var turn_stop_limit = 0.75
@export var body_tilt = 35
var jump_force
@export var MAX_JUMP_FORCE = 60.0

var speed_input = 0
var turn_input = 0

@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/garbageTruck
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/garbageTruck/wheel_frontRight
@onready var left_wheel = $CarMesh/garbageTruck/wheel_frontLeft

#func _ready():
#	ground_ray.add_exception(self)

func _physics_process(delta):
	if riding:
		freeze = paused
	if paused:
		return
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)

## hop aboard!
func _process(delta):
	if player_body != null:
		paused = player_body.paused
	
	if paused:
		return
	
	if awaiting_input == true and riding == false:
		if Input.is_action_just_pressed("interact"):
			print("riding!")
			freeze = false
			player_body.in_control = false
			in_control = true
			player_body.collision_layer = 0
			player_body.collision_mask = 0
			player_body.velocity = Vector3(0,0,0)
			player_body.global_position = $RidePos.global_position
			%BinCam.current = true
			riding = true
	elif riding == true:
		if Input.is_action_just_pressed("interact"):
			print("hopping off!")
			player_body.in_control = true
			in_control = false
			freeze = true
			player_body.global_position = $PlayerExit.global_position
			player_body.collision_layer = 1
			player_body.collision_mask = 1
			%BinCam.current = false
			riding = false

## run if vehicle is in control of inputs
	if in_control:
		## set player position equal to the position of the "seat"
		player_body.global_position = $RidePos.global_position
		#player_body.rotation = body_mesh.rotation
		
		## tilt the player while turning (WIP)
		var new_body_basis = player_body.global_transform.basis.rotated(player_body.global_transform.basis.y, turn_input)
		player_body.global_transform.basis = player_body.global_transform.basis.slerp(new_body_basis, turn_speed * delta)
		player_body.global_transform = player_body.global_transform.orthonormalized()
		var t_body = -turn_input * linear_velocity.length() / body_tilt
		player_body.rotation.z = lerp(player_body.rotation.z, t_body, 5.0 * delta)
		if ground_ray.is_colliding():
			var n_body = ground_ray.get_collision_normal()
			var xform_body = align_with_y(player_body.global_transform, n_body)
			player_body.global_transform = player_body.global_transform.interpolate_with(xform_body, 10.0 * delta)
		
		
		## actually get the inputs and convert to vectors
		if not ground_ray.is_colliding():
			return
		speed_input = Input.get_axis("move_backward", "move_forward") * acceleration
		turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
		right_wheel.rotation.y = turn_input
		left_wheel.rotation.y = turn_input
		if abs(linear_velocity.x) > abs(linear_velocity.z):
			#jump_force = linear_velocity.x
			jump_force = abs(linear_velocity.x / 2)
		else:
			#jump_force = linear_velocity.z
			jump_force = abs(linear_velocity.z / 2)
		
		## jump!
		if Input.is_action_just_pressed("jump"):
			linear_velocity.y = clamp(jump_force, 0, MAX_JUMP_FORCE)
			#linear_velocity.y = jump_force

		## tilt car
		if linear_velocity.length() > turn_stop_limit:
			var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
			car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
			car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
			var t = -turn_input * linear_velocity.length() / body_tilt
			body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
			if ground_ray.is_colliding():
				var n = ground_ray.get_collision_normal()
				var xform = align_with_y(car_mesh.global_transform, n)
				car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

## match car tilt to angle of slope
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()

## prepare to be boarded
func _on_player_detector_body_entered(body: Node3D) -> void:
	if body is player:
		awaiting_input = true
		player_body = body

## stop preparing to be boarded
func _on_player_detector_body_exited(body: Node3D) -> void:
	if body is player:
		awaiting_input = false
