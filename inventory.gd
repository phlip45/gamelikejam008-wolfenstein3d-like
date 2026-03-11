extends Resource
class_name Inventory

@export var ram:Vector2 = Vector2(4,4)
@export var virus:Vector2i = Vector2i(50,50)
@export var credit:Vector2i = Vector2i(50,200)
@export var link:Vector2i = Vector2i(0,10)

var current_weapon:GunData
@export var owned_weapons:Dictionary[GunType, GunData]

enum AmmoType{
	NULL,
	CREDIT,
	LINK,
	RAM,
	VIRUS,
}

enum GunType{
	NULL,
	BUZZSAW,
	REVOLVER,
	CLEAVER,
}

func pickup(data:PickupData) -> bool:
	match data.type:
		PickupData.Type.GUN:
			data = data as GunPickupData
			var auto_switch:bool = false
			if !owned_weapons.has(data.gundata.type):
				auto_switch = true
			owned_weapons[data.gundata.type] = data.gundata
			if auto_switch:
				switch_weapons(data.gundata)
			print(data.name, " picked up")
			return true
		PickupData.Type.AMMO:
			pass
		PickupData.Type.HEALTH:
			pass
	return false

func pickup_gun(data:PickupData) -> bool:
	return false
func pickup_ammo(data:PickupData) -> bool:
	return false
func pickup_health(data:PickupData) -> bool:
	return false

func pull_trigger(player:Player):
	current_weapon.shoot(player)
	var projectile:Projectile = current_weapon.projectile.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	projectile.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)

func switch_weapons(data:GunData):
	if !owned_weapons.has(data.type): return
	Global.player.gun_state = Player.GunState.CHANGING_WEAPON
	current_weapon = data
	await Global.ui.change_gun(data)
	Global.player.gun_state = Player.GunState.READY
	
