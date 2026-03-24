extends Projectile
class_name MeleeProjectile

var enabled:bool = true
var shooter:Actor
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup(_pos:Vector3, _rot:Vector3, enemy:Enemy = null):
	if !enemy:
		shooter = Global.player
		reparent(shooter.gun_cloaca, false)
	else:
		shooter = enemy
		faction = Faction.ENEMY
		reparent(enemy.projectile_cloaca, false)
	print(enemy)
	animation_player.play("swing")
	await animation_player.animation_finished
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if !enabled: 
		print("Disabled")
		return
	print("Working: ", body.name)
	if  body.is_in_group("enemy") and faction == Faction.PLAYER or\
		body.is_in_group("player") and faction == Faction.ENEMY:
		
		var pos = Vector3(body.global_position.x,1.5 ,body.global_position.z)
		
		#Line of sight check
		var raycast:RayCast3D = shooter.ray_cast_3d as RayCast3D
		if !raycast: push_error("UH OH! RAYCAST MISSING")
		raycast.look_at(pos)
		raycast.force_raycast_update()
		if raycast.get_collider() != body:
			return
		enabled = false
		
		deal_damage(body as Actor)
		BloodSpurt.spawn.call_deferred(pos)
		queue_free()

func deal_damage(actor:Actor):
	if actor.has_flesh():
		var _damage = Damage.create(int(randf_range(damage.x,damage.y)), Damage.Type.FRACTER)
		(actor.flesh as Flesh).damage(_damage)
