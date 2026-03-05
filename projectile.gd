extends Area3D
class_name Projectile

@export_range(0,50,0.1,"suffix:m/s") var speed:float
@export var damage_min:int = 1
@export var damage_max:int = 1
@export var life_time:float = 2.0
@export var faction:Faction = Faction.ENEMY
@export var sprite_frames:SpriteFrames
@export var animation_name:String = "Idle"
@onready var animated_sprite_3d:AnimatedSprite3D = $AnimatedSprite3D

var velocity:Vector3
var bounce_cooldown:Vector2 = Vector2(0,0.01)

enum Faction{
	NULL, PLAYER, ENEMY
}

func setup(pos:Vector3, rot:Vector3) -> void:
	global_position = pos
	rotation = rot
	velocity = -transform.basis.z.normalized() * speed

func _ready() -> void:
	animated_sprite_3d.sprite_frames = sprite_frames
	animated_sprite_3d.animation = animation_name
	animated_sprite_3d.play()

func _physics_process(delta:float) -> void:
	bounce_cooldown.x -= delta
	if position.y < 0 or position.y >3:
		velocity.y = -velocity.y
	
	var from:Vector3 = global_position
	var motion:Vector3 = velocity * delta
	var to:Vector3 = from + motion
	
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result:Dictionary = space_state.intersect_ray(query)
	
	if not result.is_empty() and bounce_cooldown.x <= 0.0:
		var collider:Node3D = result.collider
		var normal:Vector3 = result.normal
		
		if collider.is_in_group("enemy"):
			die()
			return
		if collider.has_method("apply_damage"):
			collider.apply_damage(damage_min, damage_max, faction)
		
		global_position = result.position + normal * 0.01
		velocity = velocity.bounce(normal).normalized() * speed
		look_at(global_position + velocity, Vector3.UP)
		
		bounce_cooldown.x = bounce_cooldown.y
	else:
		global_position = to
	
	life_time -= delta
	if life_time <= 0.0:
		die()

func die() -> void:
	queue_free()
