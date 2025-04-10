extends Control

@onready var icon = $InnerBorder/ItemIcon
@onready var item_name = $ItemInfo/NinePatchRect/MarginContainer/ItemTitle/ItemName
@onready var item_desc = $ItemInfo/NinePatchRect/MarginContainer/ItemTitle/ItemDescription/FlavorText

var item = null

func _ready():
	pass
	
func _process(delta):
	pass
	
#func _on_focus_entered() -> void:
	#if item != null:
		#$ItemInfo.set_global_position(Vector2(430, 300))
		#$ItemInfo.visible = true
#
#func _on_focus_exited() -> void:
	#$ItemInfo.visible = false
	
func set_empty():
	icon.texture = null

func set_item(new_item):
	item = new_item
	icon.texture = item["texture"]
	item_name.text = str(item["name"])
	item_desc.text = str(item["desc"])


func _on_item_button_focus_entered() -> void:
	if item != null:
		$ItemInfo.set_global_position(Vector2(430, 300))
		$ItemInfo.visible = true

func _on_item_button_focus_exited() -> void:
	$ItemInfo.visible = false
