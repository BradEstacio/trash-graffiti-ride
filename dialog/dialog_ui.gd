extends Control

@onready var panel = $CanvasLayer/Panel
@onready var dialog_speaker = $CanvasLayer/Panel/DialogBox/DialogSpeaker
@onready var dialog_text = $CanvasLayer/Panel/DialogBox/DialogText
@onready var dialog_options = $CanvasLayer/Panel/DialogBox/DialogOptions

func _ready():
	hide_dialog()
	
# show dialog box
func show_dialog(speaker, text, options):
	panel.visible = true
	
	# Populate data
	dialog_speaker.text = speaker
	dialog_text.text = text
	
	# Remove exisiting options
	for option in dialog_options.get_children():
		dialog_options.remove_child(option)
		
	# Populate options
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_override("Super Tasty",load("res://assets/fonts/Super Tasty.ttf"))
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(_on_option_selected.bind(option))
		dialog_options.add_child(button)
		button.grab_focus()
		

# Handle response selection	
func _on_option_selected(option):
	get_parent().handle_dialog_choice(option)
	
# hide dialog box
func hide_dialog():
	panel.visible = false

# close dialog
func _on_close_button_pressed():
	hide_dialog()
