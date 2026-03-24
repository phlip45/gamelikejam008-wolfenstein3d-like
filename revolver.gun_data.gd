extends GunData
class_name RevolverGunData

var tween:Tween
var state:State
var bullets:Vector2i = Vector2i(6,6)

enum State{
	NULL,
	IDLE,
	SHOOT,
	WIELD,
	HOLSTER,
}

var AnimStates:Dictionary[State, String]={
	State.NULL:"Idle",
	State.IDLE:"Launched",
	State.SHOOT:"Reload",
	State.WIELD:"Holster",
	State.HOLSTER:"Ready",
}

signal ready_to_shoot
signal holstered

func prepare():
	pass

func shoot(player:Player):
	Global.ui.play_gun_anim("Shoot")
	if player.inventory.credit.x <= 0:
		return
	player.inventory.use_credit(1)
	if reload.x > 0: 
		push_error("Player tried shooting when reload wasn't ready")
		return
	var bullet:RevolverProjectile = projectile.instantiate()
	player.get_tree().current_scene.add_child(bullet)
	bullet.setup(player.gun_cloaca.global_position, player.rotation,null)
	reload.x = reload.y

func change_state(new_state:State):
	state = new_state
	match new_state:
		State.IDLE:
			pass
		State.SHOOT:
			if tween: tween.kill()
			tween = Global.create_tween()
			tween.tween_callback(Global.ui.play_gun_anim.bind(AnimStates[new_state]))
			tween.tween_callback(func():
				await Global.ui.gun_sprite.animation_finished
			)
			tween.tween_callback(ready_to_shoot.emit)
			tween.tween_callback(change_state.bind(State.IDLE))
		State.HOLSTER:
			if tween: tween.kill()
			tween = Global.create_tween()
			tween.tween_callback(Global.ui.play_gun_anim.bind(AnimStates[new_state]))
			tween.tween_callback(func():
				await Global.ui.gun_sprite.animation_finished
			)
			tween.tween_callback(holstered.emit)
		State.WIELD:
			Global.ui.gun_sprite.position = ui_transform_position
			if tween: tween.kill()
			tween = Global.create_tween()
			tween.tween_callback(Global.ui.play_gun_anim.bind(AnimStates[new_state]))
			tween.tween_callback(func():
				await Global.ui.gun_sprite.animation_finished
			)
			tween.tween_callback(ready_to_shoot.emit)
			tween.tween_callback(change_state.bind(State.IDLE))
