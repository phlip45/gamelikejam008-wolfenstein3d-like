extends AnimatedSprite3D
class_name Flash

static var scene:String = "res://assets/effects/flash.tscn"

static func spawn(pos:Vector3) -> void:
	var packed_scene:PackedScene = await Global.load_scene(scene)
	var flash:Flash = packed_scene.instantiate()
	flash.position = pos
	Global.level.add_child.call_deferred(flash)

func _ready() -> void:
	animation_finished.connect(queue_free)
