extends CanvasLayer

@onready var pause_layer: CanvasLayer = $"."
@onready var fullscreen_toggle: CheckButton = $VBoxContainer/FullscreenToggle
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolumeSlider

var master_bus_index
var music_bus_index
var sfx_bus_index


func _ready() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		master_bus_index,
		value
	)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus_index,
		value
	)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bus_index,
		value
	)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
