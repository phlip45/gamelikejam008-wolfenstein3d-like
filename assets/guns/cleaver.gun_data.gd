extends GunData
class_name CleaverGunData

func shoot(player:Player):
	Global.ui.play_gun_anim("Shoot")
	if reload.x > 0: 
		push_error("Player tried shooting when reload wasn't ready")
		return
	var cleaver:MeleeProjectile = projectile.instantiate()
	player.get_tree().current_scene.add_child(cleaver)
	cleaver.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)
	reload.x = reload.y
	#change_state(State.RELOAD)
