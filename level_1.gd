extends Node3D
class_name Level

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@export var fog_colors:Array[Color]
var fog_color_index:int = 0

func _init():
	Global.level = self
	
func _ready() -> void:
	var spurt:PackedScene = await Global.load_scene("res://assets/effects/blood_spurt.tscn")
	var real_spurt:BloodSpurt = spurt.instantiate()
	add_child(real_spurt)
	cycle_colors()

func cycle_colors():
	var tween:Tween = create_tween()
	for i in fog_colors.size():
		tween.tween_property(world_environment.environment, "fog_light_color",fog_colors[i],10)
	tween.tween_callback(cycle_colors)
	
