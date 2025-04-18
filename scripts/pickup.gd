@tool
extends Area3D

@export var pickup_name = "trash"

func _on_body_entered(body: Node3D) -> void:
	if body is player or randymobile:
		Global.add_item(self)
		queue_free()
