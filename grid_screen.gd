extends Node3D
class_name GridScreen

@onready var sprite_3d: Sprite3D = $Sprite3D
var duration:float = 0.25
static var scene:String = "res://assets/effects/grid_screen.tscn"

static func spawn(pos:Vector3, rotato:float, _duration:float = 0.25) -> GridScreen:
	var _scene:PackedScene = await Global.load_scene(scene)
	var screen:GridScreen = _scene.instantiate() as GridScreen
	screen.position = pos
	screen.rotation.y = rotato
	screen.duration = _duration
	Global.level.add_child.call_deferred(screen)
	return screen

func _ready() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(sprite_3d, "modulate", Color.TRANSPARENT, duration)
	tween.tween_callback(queue_free)
