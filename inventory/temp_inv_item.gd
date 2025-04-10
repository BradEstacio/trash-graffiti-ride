@tool
extends Node3D

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_desc: String = ""
@export var item_texture: Texture
var scene_path: String = "res://inventory/inv_ui.tscn"

@onready var icon_sprite = $Sprite3D

var player_in_range = false

func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture

func _process(delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	if player_in_range and Input.is_action_just_pressed("pickup_temp"):
		get_trash()
		
func get_trash():
	var item = {
		"quantity": 1,
		"id": item_id,
		"name": item_name,
		"desc": item_desc,
		"texture": item_texture
	}
	
	if Global.player_node:
		Global.add_item(item)
		self.queue_free()
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
