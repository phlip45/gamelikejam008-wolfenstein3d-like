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
	NULL = 0,
	CLEAVER = 1,
	BUZZSAW = 2,
	REVOLVER = 3,
	CREDITS = 4,
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

func pickup_gun(_data:PickupData) -> bool:
	return false
func pickup_ammo(_data:PickupData) -> bool:
	return false
func pickup_health(_data:PickupData) -> bool:
	return false

func pull_trigger(player:Player):
	current_weapon.shoot(player)
	var projectile:Projectile = current_weapon.projectile.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	projectile.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)

func switch_weapons_by_number(gun_type:GunType):
	if owned_weapons.has(gun_type):
		switch_weapons(owned_weapons[gun_type])

func switch_weapons(data:GunData):
	if !owned_weapons.has(data.type): return
	Global.player.gun_state = Player.GunState.CHANGING_WEAPON
	current_weapon = data
	await Global.ui.change_gun(data)
	Global.player.gun_state = Player.GunState.READY
	
