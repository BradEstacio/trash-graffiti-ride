extends RigidBody3D

class_name cop

var awaiting_input = false
var riding = false

@onready var player_body: player = %Player
var angle_to_player

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

@export var crash_sounds: Array

var speed_input = 0
var turn_input = 0

@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/police
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/police/wheel_frontRight
@onready var left_wheel = $CarMesh/police/wheel_frontLeft
@onready var grill: MeshInstance3D = $CarMesh/police/grill
@onready var spawns: Array[Marker3D]
@onready var edge_detector: RayCast3D = $CarMesh/edge_detector

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _ready():
#	ground_ray.add_exception(self)
	for marker in %CopPositions.get_children():
		spawns.append(marker)
	global_position = spawns.pick_random().global_position

func _physics_process(delta):
	#if riding:
		#freeze = paused
	if paused:
		return
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
	if edge_detector.is_colliding() == false:
		jump()

## hop aboard!
func _process(delta):
	
	if player_body != null:
		paused = player_body.paused
	
	if paused:
		return

	## actually get the inputs and convert to vectors
	if not ground_ray.is_colliding():
		#print("oops")
		return
	
	if player_body.in_control == false:
		car_mesh.look_at(player_body.global_position)
		
		speed_input = acceleration
		if car_mesh.rotation.y < 0:
			turn_input = -0.33
		elif car_mesh.rotation.y > 0.5:
			turn_input = 0.33
		else:
			turn_input = 0
	#self.rotate_object_local(Vector3.UP, PI)
	
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input

	
	## jump!
	if Input.is_action_just_pressed("jump"):
		jump()
		
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

func jump():
	if abs(linear_velocity.x) > abs(linear_velocity.z):
		#jump_force = linear_velocity.x
		jump_force = abs(linear_velocity.x / 2)
	else:
		#jump_force = linear_velocity.z
		jump_force = abs(linear_velocity.z / 2)
	if ground_ray.is_colliding():
		linear_velocity.y = clamp(jump_force, 0, MAX_JUMP_FORCE)

func _on_killzone_body_entered(body: Node3D) -> void:
	if body == self:
		linear_velocity = Vector3(0,0,0)
		global_position = spawns.pick_random().global_position
		print("cop respawned!")
