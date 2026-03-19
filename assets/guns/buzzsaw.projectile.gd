class_name BuzzsawProjectile
extends Projectile

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var damage:float = 10

func setup(pos:Vector3, rot:Vector3, enemy:Enemy = null) -> void:
	if enemy:
		faction = Faction.ENEMY
		reparent(enemy.projectile_cloaca, false)
	else:
		reparent(Global.player.gun_cloaca, false)
	global_position = pos
	rotation = rot
	velocity = -transform.basis.z.normalized() * speed

func _ready() -> void:
	animated_sprite_3d.sprite_frames = sprite_frames
	animated_sprite_3d.animation = animation_name
	animated_sprite_3d.play()
	pass

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
		var normal:Vector3 = result.normal
		
		global_position = result.position + normal * 0.01
		velocity = velocity.bounce(normal).normalized() * speed
		look_at(global_position + velocity, Vector3.UP)
		
		bounce_cooldown.x = bounce_cooldown.y
	else:
		global_position = to
	
	life_time -= delta
	if life_time <= 0.0:
		die()

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("enemy") and faction == Faction.PLAYER) or\
	   (body.is_in_group("player") and faction == Faction.ENEMY):
		deal_damage(body)
		die()

func deal_damage(actor:Actor):
	if actor.has_flesh():
		(actor.flesh as Flesh).damage(damage)
