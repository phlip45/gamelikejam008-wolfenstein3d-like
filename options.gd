extends Control
class_name Options
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var mouse_slider: HSlider

func _ready() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	
	sfx_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX"))
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	
	mouse_slider.value = Global.Settings.mouse_sensitivity
	mouse_slider.value_changed.connect(_on_mouse_slider_value_changed)

func _on_music_slider_value_changed(new_value: float) -> void:
	var bus_index:int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_index,new_value)
	
	if(new_value == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
		
	if !Maestro.music_player.playing:
		Maestro.music_player.play()

func _on_sfx_slider_value_changed(new_value: float) -> void:
	var bus_index:int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(bus_index,new_value)
	
	Maestro.stop_music()
	
	if(new_value == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
	if !Maestro.sfx_player.playing:
		Maestro.sfx_player.stream = Maestro.sounds["door_open"]
		Maestro.sfx_player.play()

func play_music():
	if !Maestro.music_player.playing:
		Maestro.music_player.play(Maestro.music_player.get_playback_position())

func _on_mouse_slider_value_changed(new_value:float):
	Global.Settings.mouse_sensitivity = new_value

func _on_restart_level_btn_pressed() -> void:
	play_music()
	queue_free()
	Global.restart_level()

func _on_quit_btn_pressed() -> void:
	play_music()
	Global.scene_changer.change_scene("res://main_menu.tscn")
	queue_free()

func _on_resume_btn_pressed() -> void:
	play_music()
	queue_free()
