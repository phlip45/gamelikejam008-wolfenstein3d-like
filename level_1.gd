extends Node3D
class_name Level

@export var level_name:LevelName
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@export var kessleroids_to_unlock_exit:Vector2i
@export var fog_colors:Array[Color]
var timer:float = 0
var fog_color_index:int = 0
@export var navigation_region_3d: NavigationRegion3D
@export var player_start_location: Marker3D

signal kessleroid_killed(remaining_kessleroids:int)

enum LevelName{
	NULL=0, 
	BALLISTA=1,
	THE_LOOP=2,
	BEALE=3,
}

func _init():
	Global.level = self
	
func _ready() -> void:
	Global.level = self
	Global.player.position = player_start_location.global_position
	add_child(Global.player)
	kessleroids_to_unlock_exit.x = kessleroids_to_unlock_exit.y
	var spurt:PackedScene = await Global.load_scene("res://assets/effects/blood_spurt.tscn")
	var real_spurt:BloodSpurt = spurt.instantiate()
	add_child(real_spurt)
	cycle_colors()

func _process(delta: float) -> void:
	timer += delta

func cycle_colors():
	var tween:Tween = create_tween()
	for i in fog_colors.size():
		tween.tween_property(world_environment.environment, "fog_light_color",fog_colors[i],10)
	tween.tween_callback(cycle_colors)

func kessleroid_died():
	kessleroids_to_unlock_exit.x -= 1
	print("Kesselroid Died: " , kessleroids_to_unlock_exit)
	kessleroid_killed.emit(kessleroids_to_unlock_exit.x)
