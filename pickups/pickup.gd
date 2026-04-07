@tool
extends Area3D
class_name Pickup

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var pickup_data:PickupData = null:
	set(value):
		pickup_data = value
		_update_sprite.call_deferred()
@export var sprite_3d: Sprite3D
@export var animated_sprite_3d: AnimatedSprite3D
var animated:bool = false
signal picked_up
var sounds:Dictionary[SoundName, AudioStream]

enum SoundName{
	pickup
}
func _ready() -> void:
	_update_sprite.call_deferred()
	if !Engine.is_editor_hint():
		sounds[SoundName.pickup] = await Global.load_resource("res://sound/sfx/pickup.mp3")

func _update_sprite():
	if not is_inside_tree():
		return
	if pickup_data.sprite_frames != null:
		animated_sprite_3d.sprite_frames = pickup_data.sprite_frames
		animated_sprite_3d.animation = pickup_data.starting_anim
		animated = true
		sprite_3d.visible = false
		animated_sprite_3d.visible = true
		animated_sprite_3d.play()
	else:
		sprite_3d.texture = pickup_data.texture
		animated = false
		sprite_3d.visible = true
		animated_sprite_3d.visible = false
	sprite_3d.scale = Vector3.ONE * pickup_data.sprite_scale
	sprite_3d.position = pickup_data.sprite_position
	animated_sprite_3d.scale = Vector3.ONE * pickup_data.sprite_scale
	animated_sprite_3d.position = pickup_data.sprite_position

func die():
	picked_up.emit()
	visible = false
	collision_shape_3d.disabled = true
	play_sound(SoundName.pickup)
	audio_stream_player_3d.finished.connect(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		if player.inventory.pickup(pickup_data):
			die()

func play_sound(soundname:SoundName):
	audio_stream_player_3d.pitch_scale = randf_range(.9,1.1)
	audio_stream_player_3d.stream = sounds[soundname]
	audio_stream_player_3d.play()
