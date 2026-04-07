extends Node
class_name SceneChanger

@onready var blinder: Control = $Blinder

signal faded_out
signal faded_in

func change_scene(scene:String) -> void:
	await fade_out_screen()
	
	ResourceLoader.load_threaded_request(scene)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(scene)
			get_tree().change_scene_to_packed(loaded_scene)
			print("Succesfully Loaded: " + loaded_scene.resource_name)
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED or\
			 status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + scene)
			break
		
		await get_tree().process_frame
	await fade_in_screen()
	
func fade_out_screen():
	blinder.modulate = Color.BLACK

func fade_in_screen():
	var tween:Tween = create_tween()
	tween.tween_property(blinder,"modulate",Color.TRANSPARENT,1)
	tween.tween_callback(faded_in.emit)
	await faded_in
