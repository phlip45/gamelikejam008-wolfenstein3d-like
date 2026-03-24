class_name SnotBallProjectile
extends Projectile

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func setup(pos:Vector3, rot:Vector3, enemy:Enemy = null) -> void:
	if enemy:
		faction = Faction.ENEMY
	global_position = pos
	reparent(enemy.get_tree().current_scene)
	rotation = rot
	velocity = -transform.basis.z.normalized() * speed
	tree_exiting.connect(on_exit)

func _ready() -> void:
	animated_sprite_3d.sprite_frames = sprite_frames
	animated_sprite_3d.animation = animation_name
	if randi_range(0,1) == 0:
		animated_sprite_3d.play()
	else:
		animated_sprite_3d.play_backwards()

func _physics_process(delta:float) -> void:
	var from:Vector3 = global_position
	var motion:Vector3 = velocity * delta
	var to:Vector3 = from + motion
	global_position = to
	life_time -= delta
	if life_time <= 0.0:
		die()

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("enemy") and faction == Faction.PLAYER) or\
	   (body.is_in_group("player") and faction == Faction.ENEMY):
		var pos = Vector3(body.global_position.x,1.5 ,body.global_position.z)
		deal_damage(body)
		BloodSpurt.spawn.call_deferred(pos)
		die()
	else:
		die()

func deal_damage(actor:Actor):
	if actor.has_flesh():
		var _damage = Damage.create(int(randf_range(damage.x,damage.y)), Damage.Type.NULL)
		(actor.flesh as Flesh).damage(_damage)

func on_exit():
	Explosion.spawn(global_position)
