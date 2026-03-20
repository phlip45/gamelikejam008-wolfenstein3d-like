extends GunData
class_name BuzzsawGunData

var tween:Tween
var state:State

enum State{
	NULL,
	IDLE,
	LAUNCHED,
	RELOAD,
	HOLSTER,
	READY,
}

var AnimStates:Dictionary[State, String]={
	State.IDLE:"Idle",
	State.LAUNCHED:"Launched",
	State.RELOAD:"Reload",
	State.HOLSTER:"Holster",
	State.READY:"Ready",
}

signal ready_to_shoot
signal holstered

func prepare():
	pass

func shoot(player:Player):
	if reload.x > 0: 
		push_error("Player tried shooting when reload wasn't ready")
		return
	var saw:BuzzsawProjectile = projectile.instantiate()
	player.get_tree().current_scene.add_child(saw)
	saw.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)
	reload.x = reload.y
	change_state(State.RELOAD)

func change_state(new_state:State):
	state = new_state
	match new_state:
		State.RELOAD:
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
		State.READY:
			Global.ui.gun_sprite.position = ui_transform_position
			if tween: tween.kill()
			tween = Global.create_tween()
			tween.tween_callback(Global.ui.play_gun_anim.bind(AnimStates[new_state]))
			tween.tween_callback(func():
				await Global.ui.gun_sprite.animation_finished
			)
			tween.tween_callback(ready_to_shoot.emit)
			tween.tween_callback(change_state.bind(State.IDLE))
