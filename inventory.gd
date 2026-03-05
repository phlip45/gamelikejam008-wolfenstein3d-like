extends Resource
class_name Inventory

@export var ram:Vector2i = Vector2i(50,200)
@export var virus:Vector2i = Vector2i(0,200)
@export var credit:Vector2i = Vector2i(0,200)
@export var link:Vector2i = Vector2i(0,200)
var current_weapon:GunData
var owned_weapons:Dictionary[String, GunData]

func pickup(data:PickupData) -> bool:
	match data.type:
		PickupData.Type.GUN:
			if data.subtype == PickupData.Subtype.PISTOL:
				#pistol = true
				#bullets = min(bullets + 10, bullets_max)
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
