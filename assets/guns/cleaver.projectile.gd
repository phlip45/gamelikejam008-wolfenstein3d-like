extends Projectile
class_name CleaverProjectile

var enabled:bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup(pos:Vector3, rot:Vector3):
	global_position = pos
	rotation = rot
	animation_player.play("swing")
	await animation_player.animation_finished
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and enabled:
		var pos = Vector3(body.global_position.x,1.5 ,body.global_position.z)
		enabled = false
		body.damage(10)
		BloodSpurt.spawn.call_deferred(pos)
		queue_free()
		
	
