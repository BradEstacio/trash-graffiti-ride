extends Control

@onready var grid_container = $CanvasLayer/GridContainer
@onready var trash_count: Label = $CanvasLayer/trash_count


func _ready():
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	$CanvasLayer/GridContainer/Inv_UI_Slot/ItemButton.grab_focus()
	
func _process(delta):
	trash_count.text = str(Global.trash_count)
	
func initialize_focus():
	$CanvasLayer/GridContainer/Inv_UI_Slot/ItemButton.grab_focus()
	
func _on_inventory_updated():
	clear_grid_container()
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
		
