extends CharacterBody3D

@export var npc_id: String
@export var npc_name: String

var awaiting_input = false
var player_body

@onready var dialog_manager = $DialogManager
@export var dialog_resource: Dialog
var current_state = "start"
var current_branch_index = 0

@export var quests: Array[Quest] = []
var quest_manager: Node = null

func start_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if npc_dialogs.is_empty():
		# Unpause after dialog ends
		if player_body != null:
			player_body.paused = false
		return
	dialog_manager.show_dialog(self)
	# Unpause after dialog ends
	if player_body != null:
		player_body.paused = false
		
# Get current branch dialog
func get_current_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog 
	return null
	
func set_dialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"
	
func set_dialog_state(state):
	current_state = state
	
func offer_quest(quest_id: String):
	print("Attempting to offer quest: ", quest_id)
	
	for quest in quests:
		if quest.quest_id == quest_id and quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.add_quest(quest)
			return
	
	print("Quest not found or started already.")
	
func get_quest_dialog() -> Dictionary:
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and not objective.is_completed:
				if current_state == "start":
					return {"text": objective.objective_dialog, "options": {}}
	return {"text": "", "options": {}}

func _ready():
	# Load dialog data
	dialog_resource.load_from_json("res://dialog/dialog_data.json")
	dialog_manager.npc = self
	quest_manager = Global.player_node.get_node("Inv_UI/QuestManager")
	print("Quest Manager: ", quest_manager)
	#quest_manager = Global.player_node.Inv_UI.QuestManager
	print("NPC Ready. Quests loaded: ", quests.size())

func _process(delta: float) -> void:
	if awaiting_input:
		if Input.is_action_just_pressed("interact"):
			if player_body != null:
				player_body.paused = true
			start_dialog()
			

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is player:
		awaiting_input = true
		player_body = body


func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is player:
		awaiting_input = false
		player_body = null
