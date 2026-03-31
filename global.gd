extends Node

var player:Player
var ui:UI
var level:Level
var level_times:Dictionary[int, String] = {
	1:"null",
	2:"null",
	3:"null",
}
var save_scenes:Dictionary[String, PackedScene]
var save_resources:Dictionary[String, Resource]
@onready var scene_changer: SceneChanger = $SceneChanger



func _ready() -> void:
	load_new_player()

func load_new_player():
	var player_scene:PackedScene = await load_resource("res://player.tscn")
	player = player_scene.instantiate()

func load_resource(resource_path:String) -> Resource:
	if save_resources.has(resource_path):
		return save_resources[resource_path]
	
	ResourceLoader.load_threaded_request(resource_path)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(resource_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(resource_path)
			save_resources[resource_path] = loaded_scene
			return loaded_scene
		elif status == ResourceLoader.THREAD_LOAD_FAILED or\
			 status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + resource_path)
			break
		
		await get_tree().process_frame
	return null

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

func restart_level():
	level.queue_free()
	ui.queue_free()
	player.queue_free()
	load_new_player()
	scene_changer.change_scene.call_deferred("res://level_1.tscn")

func finish_level():
	
	get_tree().change_scene_to_file.call_deferred("res://main_menu.tscn")

class Settings:
	static var mouse_sensitivity:float = 3.0
	static var difficulty:Difficulty = Difficulty.NORMAL
	enum Difficulty{
		NULL, EASY, NORMAL, HARD, ULTRA
	}
