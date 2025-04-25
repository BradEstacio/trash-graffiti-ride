extends CharacterBody3D
class_name player

#@onready var camera_3d = $Camera3D

@onready var camera_3d := %POVCam as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@onready var character_mover = $CharacterMover
@onready var normal_speed = character_mover.max_speed
@onready var normal_accel = character_mover.move_accel
@onready var inv_quest: Control = $InvQuest
@onready var inventory_ui: Control = $InvQuest/Inv_UI
@onready var grid_container: GridContainer = $InvQuest/Inv_UI/CanvasLayer/GridContainer
@onready var trash_count: Label = $InvQuest/Inv_UI/CanvasLayer/trash_count
@onready var trash_label: Label = $InvQuest/Inv_UI/CanvasLayer/trash_label
@onready var collectibles_img: Sprite2D = $InvQuest/Inv_UI/CanvasLayer/CollectiblesIMG
@onready var mini_map: ColorRect = %MiniMap
@onready var pause_layer: CanvasLayer = $Pause/PauseLayer

@export var look_sensitivity_h = 0.15
@export var look_sensitivity_v = 0.15
@onready var quest_panel: Panel = $InvQuest/QuestManager/QuestUI/CanvasLayer/Panel
@onready var quest_manager: Control = $InvQuest/QuestManager
@onready var tag_cast: RayCast3D = $CameraPivot/SpringArm3D/POVCam/TagCast
@onready var reticle: Sprite3D = $CameraPivot/SpringArm3D/POVCam/TagCast/reticle
@onready var reference_point: Marker3D = $CameraPivot/SpringArm3D/POVCam/TagCast/reference_point

@export var basic_tags: Array
@export var basic_tag_sounds: Array[AudioStream]

@export var jump_sfx: Array[AudioStream]

var paused = false
var in_control := true
var can_move = true
var story_moment = false
var map_toggled_on = true

var tag_dist

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
	pass
	#for reward in quest.rewards:
		#if reward.reward_type == "Building Tag Paint":
			#
	#
	#quest_manager.update_quest(quest.quest_id, "completed")


func _on_quest_updated(quest_id: String):
	var quest = quest_manager.get_quest(quest_id)

func _ready():
	Global.set_player_reference(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		paused = !paused
		#$Settings.visible = !$Settings.visible
		pause_layer.visible = !pause_layer.visible
		pause_layer.fullscreen_toggle.grab_focus()
		if map_toggled_on:
			%MiniMap.visible = !%MiniMap.visible
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if paused == true:
		return
		
	if Input.is_action_just_pressed("map_toggled"):
		map_toggled_on = !map_toggled_on
		mini_map.visible = !mini_map.visible
	
	if tag_cast.is_colliding() and not story_moment and in_control:
		var tag_point = tag_cast.get_collision_point()
		reference_point.global_position = tag_point
		reticle.position.z = reference_point.position.z + 1
		if reticle.position.z > -3:
			reticle.visible = false
		else:
			reticle.visible = true
		print(reticle.position.z)
	else:
		reticle.visible = false
	
	
	if in_control:
		if Input.is_action_just_pressed("tag"):
			if tag_cast.is_colliding() and not story_moment and reticle.visible:
				var new_tag = Sprite3D.new()
				new_tag.texture = basic_tags.pick_random()
				var tag_transform = Transform3D(basis, reticle.global_position)
				new_tag.transform = tag_transform
				new_tag.scale = Vector3(0.3,0.3,0.3)
				get_parent().add_child(new_tag)
				var tag_sound = basic_tag_sounds.pick_random()
				$AudioStreamPlayer.set_stream(tag_sound)
				$AudioStreamPlayer.play()
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
	if in_control:
		if Input.is_action_pressed("look_right"):
			rotate_y(-look_sensitivity_h)
		if Input.is_action_pressed("look_left"):
			rotate_y(look_sensitivity_h)
		if Input.is_action_pressed("look_up"):
			camera_3d.rotate_x(look_sensitivity_v)
			#camera_3d.rotation.x = clamp(camera_3d.rotation.x, -1.5708/2, 1.5708/2)
		if Input.is_action_pressed("look_down"):
			camera_3d.rotate_x(-look_sensitivity_v)
			#camera_3d.rotation.x = clamp(camera_3d.rotation.x, -1.5708/2, 1.5708/2)

func _input(event: InputEvent) -> void:
	# Inventory
	if event.is_action_pressed("inventory"):
		inv_quest.visible = !inv_quest.visible
		inventory_ui.visible = !inventory_ui.visible
		grid_container.visible = !grid_container.visible
		trash_count.visible = !trash_count.visible
		trash_label.visible = !trash_label.visible
		collectibles_img.visible = !collectibles_img.visible
		quest_panel.visible = !quest_panel.visible
		if map_toggled_on:
			%MiniMap.visible = !%MiniMap.visible
		inventory_ui.initialize_focus()
		paused = !paused
