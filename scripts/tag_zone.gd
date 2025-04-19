extends Area3D

@onready var big_tag: Sprite3D = $Big_Tag
var not_tagged = true
var awaiting_input = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tag") and awaiting_input:
		big_tag.visible = true
		not_tagged = false

func _on_body_entered(body: Node3D) -> void:
	if not_tagged and body is player or body is randymobile:
		awaiting_input = true
		if body is player:
			body.story_moment = true
		elif body is randymobile:
			body.player_body.story_moment = true
	




func _on_body_exited(body: Node3D) -> void:
	awaiting_input = false
	if body is player or body is randymobile:
		if body is player:
			body.story_moment = false
		elif body is randymobile:
			body.player_body.story_moment = false
