extends Trigger
class_name WalkOnTrigger

@export var collision_shape_3d: CollisionShape3D

signal trigger

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		trigger.emit()

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var active:bool = false:
	set(value):
		active = value
		update_sprite()

func _ready():
	update_sprite()

func update_sprite():
	if active:
		animated_sprite_3d.animation = "Active"
	else:
		animated_sprite_3d.animation = "Inactive"
	animated_sprite_3d.play()

func _on_body_entered(body: Node3D) -> void:
	if !active: return
	if body is Player:
		trigger.emit()
