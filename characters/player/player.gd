extends CharacterBody3D
class_name player

#@onready var camera_3d = $Camera3D

@onready var camera_3d := %POVCam as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@onready var character_mover = $CharacterMover
@onready var normal_speed = character_mover.max_speed
@onready var normal_accel = character_mover.move_accel
@onready var inventory_ui = $Inv_UI

@export var look_sensitivity_h = 0.15
@export var look_sensitivity_v = 0.15
@onready var quest_panel: Panel = $Inv_UI/QuestManager/QuestUI/CanvasLayer/Panel
@onready var quest_manager: Control = $Inv_UI/QuestManager

var paused = false
var in_control := true
var can_move = true

var dir

var quest_list = null
var selected_quest: Quest = null

func is_item_needed(item_id: String) -> bool:
	# IMPORTANT: ITEM PICKUPS NEED TO CHECK IF THEY'RE NEEDED FOR A QUEST
	if selected_quest != null:
		for objective in selected_quest.quest.objectives:
			if objective.target_id == item_id and objective.target_type == "collection" and not objective.is_completed:
				return true
	return false
	
func check_quest_objectives(target_id: String, target_type: String, quantity: int = 1):
	if selected_quest == null:
		return
		
	var objective_updated = false
	for objective in selected_quest.objectives:
		if objective.target_id == target_id and objective.target_type == target_type and not objective.is_completed:
			print("Completing objective for quest: ", selected_quest.quest_name)
			selected_quest.complete_objective(objective.id, quantity)
			objective_updated = true
			break
			
	if objective_updated:
		if selected_quest.is_completed():
			handle_quest_completion(selected_quest)

func handle_quest_completion(quest: Quest):
	# IMPLEMENT FOR CERTAIN QUESTS TO GIVE COLLECTIBLES
	pass
	#for reward in quest.rewards:
		#if reward.reward_type == "coins":
			#coin_amount += reward.reward_amount
		#quest_manager.update_quest(quest.quest_id, "completed")

# CODE FROM TUTORIAL BUT KEPT IN TO UNDERSTAND - MIGHT NEED TO BE DELETED
#func update_quest_tracker(quest: Quest):
	#if quest:
		#quest_tracker.visible = true
		#title.text = quest.quest_name
		#
		#for child in objectives.get_children():
			#objectives.remove_child(child)
		#
		#for objective in quest.objectives:
			#var label = Label.new()
			#label.text = objective.description
			#
			#if 

func _on_quest_updated(quest_id: String):
	var quest = quest_manager.get_quest(quest_id)
	#if quest == selected_quest:
		#update_quest_tracker(quest)

func _ready():
	Global.set_player_reference(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		paused = !paused
		#$Settings.visible = !$Settings.visible
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if paused == true:
		return
		
	if in_control:
		
		if Input.is_action_pressed("run"):
			character_mover.max_speed = normal_speed * 2
			character_mover.move_accel = normal_accel * 2
		else:
			character_mover.max_speed = normal_speed
			character_mover.move_accel = normal_accel
		
		if Input.is_action_pressed("move_forward"):
			$AnimatedSprite3D.play("forward")
			$AnimatedSprite3D.flip_h = false
			dir = "forward"
		elif Input.is_action_pressed("move_backward"):
			$AnimatedSprite3D.play("back")
			$AnimatedSprite3D.flip_h = false
			dir = "back"
		else:
			if dir == "forward":
				$AnimatedSprite3D.play("forward_stand")
				$AnimatedSprite3D.flip_h = true
			elif dir == "back":
				$AnimatedSprite3D.play("back_stand")
				$AnimatedSprite3D.flip_h = false
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		character_mover.set_move_dir(move_dir)
		if Input.is_action_just_pressed("jump"):
			character_mover.jump()


func _physics_process(delta: float) -> void:
	if paused:
		return
	if Input.is_action_pressed("look_right"):
		rotate_y(-look_sensitivity_h)
	if Input.is_action_pressed("look_left"):
		rotate_y(look_sensitivity_h)
	if Input.is_action_pressed("look_up"):
		camera_3d.rotate_x(look_sensitivity_v)
	if Input.is_action_pressed("look_down"):
		camera_3d.rotate_x(-look_sensitivity_v)

func _input(event: InputEvent) -> void:
	# Inventory
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		quest_panel.visible = !quest_panel.visible
		inventory_ui.initialize_focus()
		paused = !paused

#func is_item_needed(item_id: String) -> bool:
		
