extends GunData
class_name CleaverGunData

func shoot(player:Player):
	Global.ui.play_gun_anim("Shoot")
	var out_of_ammo:bool = false
	if player.inventory.credit.x <= 0:
		out_of_ammo = true
	if reload.x > 0: 
		push_error("Player tried shooting when reload wasn't ready")
		return
	player.play_sound(Player.SoundName.chop)
	var cleaver:MeleeProjectile = projectile.instantiate()
	if out_of_ammo:
		cleaver.damage *= 0.5
	player.inventory.use_credit(1)
	player.get_tree().current_scene.add_child(cleaver)
	cleaver.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)
	reload.x = reload.y
	#change_state(State.RELOAD)
