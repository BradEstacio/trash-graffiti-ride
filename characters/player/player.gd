extends CharacterBody3D
class_name player

#@onready var camera_3d = $Camera3D

@onready var camera_3d := %POVCam as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@onready var character_mover = $CharacterMover
@onready var normal_speed = character_mover.max_speed
@onready var normal_accel = character_mover.move_accel

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

var paused = false
var in_control := true


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if paused == true:
			return
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		_camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		_camera_pivot.rotation_degrees.x = clamp(_camera_pivot.rotation_degrees.x, -90, 90)

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		paused = !paused
		#$Settings.visible = !$Settings.visible
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if paused == true:
		return
		
	if in_control:
		
		if Input.is_action_pressed("run"):
			character_mover.max_speed = normal_speed * 2
			character_mover.move_accel = normal_accel * 2
		else:
			character_mover.max_speed = normal_speed
			character_mover.move_accel = normal_accel
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		character_mover.set_move_dir(move_dir)
		if Input.is_action_just_pressed("jump"):
			character_mover.jump()
