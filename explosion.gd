extends AnimatedSprite3D
class_name Explosion

static var scene:String = "res://assets/effects/explosion.tscn"
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

static func spawn(pos:Vector3, _scale:float = 1.0) -> void:
	var packed_scene:PackedScene = await Global.load_scene(scene)
	var explosion:Explosion = packed_scene.instantiate()
	
	
	explosion.position = pos
	explosion.scale *= _scale
	Global.level.add_child.call_deferred(explosion)

func _ready() -> void:
	var sound:AudioStream = await Global.load_resource("res://sound/sfx/explosion.mp3")
	audio_stream_player_3d.stream = sound
	audio_stream_player_3d.play()
	animation_finished.connect(queue_free)
