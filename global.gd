extends Node

var player:Player
var ui:UI
var level:Level
var save_scenes:Dictionary[String, PackedScene]
@onready var scene_changer: SceneChanger = $SceneChanger

func load_scene(scene:String) -> PackedScene:
	if save_scenes.has(scene):
		return save_scenes[scene]
	
	ResourceLoader.load_threaded_request(scene)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(scene)
			save_scenes[scene] = loaded_scene
			return loaded_scene
		elif status == ResourceLoader.THREAD_LOAD_FAILED or\
			 status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + scene)
			break
		
		await get_tree().process_frame
	return null

class Settings:
	static var mouse_sensitivity:float = 3.0
