extends Area3D

@onready var tag_here: Sprite3D = $Tag_Here
@onready var big_tag: Sprite3D = $Big_Tag
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var not_tagged = true
var awaiting_input = false
var going_up = true

@export var initial_shakes: Array[AudioStream]
@export var spray_sounds: Array[AudioStream]

func _process(delta: float) -> void:
	if going_up:
		if tag_here.position.y <= 1:
			tag_here.position.y += 0.01
		else:
			going_up = false
			
	elif going_up == false:
		if tag_here.position.y >= 0:
			tag_here.position.y -= 0.01
		else:
			going_up = true
	if Input.is_action_just_pressed("tag") and awaiting_input:
		var spray_sound = spray_sounds.pick_random()
		audio_stream_player.set_stream(spray_sound)
		audio_stream_player.play()
		big_tag.visible = true
		not_tagged = false
		tag_here.visible = false

func _on_body_entered(body: Node3D) -> void:
	if not_tagged and body is player or body is randymobile:
		tag_here.visible = true
		awaiting_input = true
		var initial_shake = initial_shakes.pick_random()
		audio_stream_player.set_stream(initial_shake)
		audio_stream_player.play()
		if body is player:
			awaiting_input = true
			body.story_moment = true
	


func _on_body_exited(body: Node3D) -> void:
	if body is player or body is randymobile:
		tag_here.visible = false
		awaiting_input = false
		if body is player:
			body.story_moment = false
		elif body is randymobile:
			body.player_body.story_moment = false
