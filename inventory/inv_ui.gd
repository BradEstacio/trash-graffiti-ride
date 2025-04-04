extends Control

@onready var grid_container = $NinePatchRect/GridContainer

func _ready():
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	
func _on_inventory_updated():
	clear_grid_container()

func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

#@onready var inv: Inv = preload("res://inventory/player_inv.tres")
#@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
#
#var is_open = false
#
#func open():
	#visible = true
	#is_open = true
#
#func close():
	#visible = false
	#is_open = false
	#
#func update_slots():
	#for i in range(min(inv.items.size(), slots.size())):
		#slots[i].update(inv.items[i])
#
#func _ready():
	#update_slots()
	#close()
	#
#func _process(delta):
	#if Input.is_action_just_pressed("inventory"):
		#if is_open:
			#close()
		#else:
			#open()
