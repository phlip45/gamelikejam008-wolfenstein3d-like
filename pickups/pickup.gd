extends Area3D
class_name Pickup

@export var pickup_data:PickupData
@onready var sprite_3d: Sprite3D = $CollisionShape3D/Sprite3D

signal picked_up

func _ready() -> void:
	sprite_3d.texture = pickup_data.texture

func die():
	picked_up.emit()
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		if player.inventory.pickup(pickup_data):
			die()
