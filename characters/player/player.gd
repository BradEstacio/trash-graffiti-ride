extends CharacterBody3D
class_name player

#@onready var camera_3d = $Camera3D

@onready var camera_3d := %POVCam as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@onready var character_mover = $CharacterMover
@onready var normal_speed = character_mover.max_speed
@onready var normal_accel = character_mover.move_accel
@onready var inventory_ui = $Inv_UI

@export var look_sensitivity_h = 0.15
@export var look_sensitivity_v = 0.15

var paused = false
var in_control := true
var can_move = true

var dir

func _ready():
	Global.set_player_reference(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#if paused == true:
			#return
		#rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		#_camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		#_camera_pivot.rotation_degrees.x = clamp(_camera_pivot.rotation_degrees.x, -90, 90)
	

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		paused = !paused
		#$Settings.visible = !$Settings.visible
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if paused == true:
		return
		
	if in_control:
		
		if Input.is_action_pressed("run"):
			character_mover.max_speed = normal_speed * 2
			character_mover.move_accel = normal_accel * 2
		else:
			character_mover.max_speed = normal_speed
			character_mover.move_accel = normal_accel
		
		if Input.is_action_pressed("move_forward"):
			$AnimatedSprite3D.play("forward")
			$AnimatedSprite3D.flip_h = false
			dir = "forward"
		elif Input.is_action_pressed("move_backward"):
			$AnimatedSprite3D.play("back")
			$AnimatedSprite3D.flip_h = false
			dir = "back"
		else:
			if dir == "forward":
				$AnimatedSprite3D.play("forward_stand")
				$AnimatedSprite3D.flip_h = true
			elif dir == "back":
				$AnimatedSprite3D.play("back_stand")
				$AnimatedSprite3D.flip_h = false
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		character_mover.set_move_dir(move_dir)
		if Input.is_action_just_pressed("jump"):
			character_mover.jump()


func _physics_process(delta: float) -> void:
	if paused:
		return
	if Input.is_action_pressed("look_right"):
		rotate_y(-look_sensitivity_h)
	if Input.is_action_pressed("look_left"):
		rotate_y(look_sensitivity_h)
	if Input.is_action_pressed("look_up"):
		camera_3d.rotate_x(look_sensitivity_v)
	if Input.is_action_pressed("look_down"):
		camera_3d.rotate_x(-look_sensitivity_v)

func _input(event: InputEvent) -> void:
	# Inventory
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		inventory_ui.initialize_focus()
		paused = !paused
