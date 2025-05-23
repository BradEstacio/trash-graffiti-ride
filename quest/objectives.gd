extends Resource

class_name Objectives

@export var id: String
@export var description: String

@export var target_id: String
@export var target_type: String

@export var objective_dialog: String = ""

@export var required_quantity: int = 0
@export var collected_quantity: int = 0
@export var locations_tagged: int = 0

@export var is_completed: bool = false
