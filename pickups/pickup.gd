@tool
extends Area3D
class_name Pickup

@export var pickup_data:PickupData:
	set(value):
		pickup_data = value
		_update_sprite.call_deferred()
@export var sprite_3d: Sprite3D
@export var animated_sprite_3d: AnimatedSprite3D
var animated:bool = false
signal picked_up

func _ready() -> void:
	_update_sprite.call_deferred()

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
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		if player.inventory.pickup(pickup_data):
			die()
