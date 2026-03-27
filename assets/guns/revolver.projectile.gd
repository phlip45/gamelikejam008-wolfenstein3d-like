extends Projectile
class_name RevolverProjectile

func setup(_pos:Vector3,_rot:Vector3, _enemy:Enemy):
	pass

func _ready() -> void:
	var ray_cast:RayCast3D = Global.player.ray_cast_3d
	ray_cast.force_raycast_update()
	var collider = ray_cast.get_collider()
	if collider and collider is Enemy:
		var enemy:Enemy = collider as Enemy
		var pos:Vector3 = enemy.global_position
		pos.y = 1.5
		BloodSpurt.spawn.call_deferred(pos)
		deal_damage(enemy)
	die()

func deal_damage(actor:Actor):
	if actor.has_flesh():
		var _damage = Damage.create(int(randf_range(damage.x,damage.y)), Damage.Type.KILLER)
		(actor.flesh as Flesh).damage(_damage)
