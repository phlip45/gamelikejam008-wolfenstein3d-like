extends Resource
class_name Inventory

#@export var ram:Vector2 = Vector2(4,4)
#@export var virus:Vector2i = Vector2i(50,50)
@export var credit:Vector2i = Vector2i(50,200)
#@export var link:Vector2i = Vector2i(0,10)

var current_weapon:GunData
@export var owned_weapons:Dictionary[GunType, GunData]

signal credit_changed(new_amount:int)

enum AmmoType{
	NULL,
	CREDIT,
	#LINK,
	#RAM,
	#VIRUS,
}

enum GunType{
	NULL = 0,
	CLEAVER = 1,
	REVOLVER = 2,
	BUZZSAW = 3,
	CREDITS = 4,
}

func pickup(data:PickupData) -> bool:
	match data.type:
		PickupData.Type.GUN:
			return pickup_gun(data)
		PickupData.Type.AMMO:
			var ammo_data = data as AmmoPickupData
			return pickup_ammo(ammo_data)
		PickupData.Type.HEALTH:
			var health_data:HealthPickupData = data as HealthPickupData
			var should_use:bool = false
			if health_data.overheal_allowed:
				should_use = true
			elif !health_data.overheal_allowed and !Global.player.flesh.is_hale():
				should_use = true
			if should_use:
				health_data.heal(Global.player.flesh)
				return true
	return false

func pickup_gun(data:PickupData) -> bool:
	var gun:GunPickupData = data as GunPickupData
	var auto_switch:bool = false
	print(gun)
	if !owned_weapons.has(gun.gundata.type):
		auto_switch = true
	owned_weapons[gun.gundata.type] = gun.gundata
	if auto_switch:
		switch_weapons(gun.gundata)
		print(data.name, " picked up")
		return true
	else:
		var pickup_ammo_instead:AmmoPickupData = AmmoPickupData.new()
		pickup_ammo_instead.amount = 10
		return pickup_ammo(pickup_ammo_instead)
	
func pickup_ammo(data:AmmoPickupData) -> bool:
	if credit.x == credit.y:
		return false
	credit.x += data.amount
	credit.x = min(credit.x, credit.y)
	credit_changed.emit(credit.x)
	return true
func pull_trigger(player:Player):
	current_weapon.shoot(player)
	#var projectile:Projectile = current_weapon.projectile.instantiate()
	#player.get_tree().current_scene.add_child(projectile)
	#projectile.setup(player.gun_cloaca.global_position, player.camera_3d.rotation)

func switch_weapons_by_number(gun_type:GunType, override:bool = false):
	if !current_weapon: return
	if current_weapon.type == gun_type and !override: return
	if owned_weapons.has(gun_type):
		switch_weapons(owned_weapons[gun_type])

func switch_weapons(data:GunData):
	if !owned_weapons.has(data.type): return
	current_weapon = data
	Global.player.gun_state = Player.GunState.CHANGING_WEAPON
	await Global.ui.change_gun(data)
	Global.player.gun_state = Player.GunState.READY
	
func use_credit(amount:int):
	credit.x -= amount
	credit.x = clamp(credit.x, 0, credit.y)
	credit_changed.emit(credit.x)
	
