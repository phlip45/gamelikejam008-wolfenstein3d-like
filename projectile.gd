@abstract
extends Area3D
class_name Projectile

@export_range(0,50,0.1,"suffix:m/s") var speed:float
@export var damage:Vector2 = Vector2(5,10)
@export var life_time:float = 2.0
@export var faction:Faction = Faction.PLAYER
@export var sprite_frames:SpriteFrames
@export var animation_name:String = "Idle"

var velocity:Vector3
var bounce_cooldown:Vector2 = Vector2(0,0.01)

enum Faction{
	NULL, PLAYER, ENEMY
}

func die() -> void:
	queue_free()

@abstract func setup(pos:Vector3, rot:Vector3,enemy:Enemy)
