extends Projectile
class_name BigBulletProjectile

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func setup(pos:Vector3,rot:Vector3):
	global_position = pos
	rotation = rot
	velocity = -transform.basis.z.normalized() * speed

func _process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0: queue_free()
	speed += delta
	velocity = -transform.basis.z.normalized() * speed

func hit(player:Player):
	player.damage(randi_range(damage_min,damage_max))
	collision_shape_3d.disabled = true
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		hit(body as Player)
	if body.is_in_group("wall"):
		queue_free()
