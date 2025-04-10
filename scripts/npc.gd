extends CharacterBody3D

@export var npc_id: String
@export var npc_name: String

var awaiting_input = false
var player_body

func start_dialog():
	print("Hello world!")
	# Unpause after dialog ends
	if player_body != null:
		player_body.paused = false
	

func _process(delta: float) -> void:
	if awaiting_input:
		if Input.is_action_just_pressed("interact"):
			if player_body != null:
				player_body.paused = true
			start_dialog()
			

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is player:
		awaiting_input = true
		player_body = body


func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is player:
		awaiting_input = false
		player_body = null
