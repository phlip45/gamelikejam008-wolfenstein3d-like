extends Trigger
class_name WalkOnTrigger

@export var collision_shape_3d: CollisionShape3D

signal trigger

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		trigger.emit()
