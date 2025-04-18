@tool
extends Node3D

@export var random_trash: Dictionary
var sound_effect

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_desc: String = ""
@export var item_texture: Texture
var scene_path: String = "res://inventory/inv_ui.tscn"

#@onready var icon_sprite = $Sprite3D

var player_in_range = false
var not_picked_up = true

func _ready():
	var dictionary_keys = random_trash.keys()
	var rand_key = dictionary_keys.pick_random()
	#sound_effect = random_trash.get(rand_key)
	var rand_texture = rand_key.instantiate()
	rand_texture.scale *= 0.5
	rand_texture.position.y += 0.75
	self.add_child(rand_texture)
	$AudioStreamPlayer.set_stream(random_trash[rand_key])
	#if not Engine.is_editor_hint():
		#icon_sprite.texture = item_texture

#func _process(delta):
	#if Engine.is_editor_hint():
		#icon_sprite.texture = item_texture
	#if player_in_range and Input.is_action_just_pressed("pickup_temp"):
		#get_trash()



func get_trash():
	var item = {
		"quantity": 1,
		"id": item_id,
		"name": item_name,
		"desc": item_desc,
		"texture": item_texture
	}
	
	if Global.player_node:
		if item_id == "0":
			Global.add_trash()
			$AudioStreamPlayer.playing = true
		else:
			Global.add_item(item)
			self.queue_free()


func _on_body_entered(body: Node3D) -> void:
	if (body is player or randymobile) and not_picked_up:
		get_trash()
		not_picked_up = false
		visible = false


func _on_audio_stream_player_3d_finished() -> void:
	queue_free() # Replace with function body.
