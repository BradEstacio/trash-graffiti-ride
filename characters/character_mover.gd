extends Node3D

@export var jump_force = 15.0
@export var gravity = 30.0

@export var max_speed = 15.0
@export var move_accel = 4.0
@export var stop_drag = 0.9

@onready var label_2: Label = $"../CameraPivot/Label2"

var character_body : CharacterBody3D
var move_drag = 0.0
var move_dir : Vector3

@export var max_jumps = 2
var jumps_spent = 0

func _ready():
	character_body = get_parent()
	move_drag = float(move_accel) / max_speed

func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir

func jump():
	if character_body.in_control:
		if character_body.is_on_floor() or jumps_spent < max_jumps - 1:
			character_body.velocity.y = jump_force
			jumps_spent += 1
			$"../AudioStreamPlayer".set_stream(get_parent().jump_sfx.pick_random())
			$"../AudioStreamPlayer".play()

func _physics_process(delta):
	if character_body.in_control:
		if character_body.paused:
			return
		if character_body.is_on_floor():
			jumps_spent = 0
		if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
			character_body.velocity.y = 0.0
		if not character_body.is_on_floor():
			character_body.velocity.y -= gravity * delta
		
		var drag = move_drag
		if move_dir.is_zero_approx():
			drag = stop_drag
		
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0
		character_body.velocity += move_accel * move_dir - flat_velo * drag
		label_2.text = str(character_body.velocity)
		
		character_body.move_and_slide()
