extends Node

# Inventory items
var inventory = []
var trash_count = 0
var story_tags = 1

# Custom signals
signal inventory_updated
signal player_referenced

var player_node: Node = null
@onready var inventory_slot_scene = preload("res://inventory/inv_ui_slot.tscn")

func _ready():
	inventory.resize(6)

func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["id"] == item["id"] and inventory[i]["name"] == item["name"] and inventory[i]["desc"] == item["desc"]:
			inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			print("Item added ", inventory)
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			print("Item added", inventory)
			return true
	return false

func add_trash():
	trash_count += 1

func remove_item():
	inventory_updated.emit()

func set_player_reference(node):
	player_node = node
	#print(player_node.get_node("Inv_UI/QuestManager"))
