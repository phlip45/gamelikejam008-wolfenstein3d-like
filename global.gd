extends Node

var player:Player
var ui:UI
var level:Level

@onready var scene_changer: SceneChanger = $SceneChanger

class Settings:
	static var mouse_sensitivity:float = 3.0

func load_scene(scene:String) -> PackedScene:
	ResourceLoader.load_threaded_request(scene)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(scene)
			return loaded_scene
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED or\
			 status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + scene)
			break
		
		await get_tree().process_frame
	return null
