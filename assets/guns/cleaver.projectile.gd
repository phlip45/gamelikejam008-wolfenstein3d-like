extends Projectile
class_name MeleeProjectile

var enabled:bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup(pos:Vector3, rot:Vector3, enemy:Enemy = null):
	if !enemy:
		reparent(Global.player.gun_cloaca, false)
	else:
		reparent(enemy.projectile_cloaca, false)
	animation_player.play("swing")
	await animation_player.animation_finished
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if !enabled: return
	if  body.is_in_group("enemy") and faction == Faction.PLAYER or\
		body.is_in_group("player") and faction == Faction.ENEMY:
		
		var pos = Vector3(body.global_position.x,1.5 ,body.global_position.z)
		enabled = false
		body.damage(10)
		BloodSpurt.spawn.call_deferred(pos)
		queue_free()
		
	
