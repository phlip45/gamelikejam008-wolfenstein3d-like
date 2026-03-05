extends Resource
class_name PickupData

@export var name:String
@export var type:Type
@export var subtype:Subtype
@export var amount:int
@export var texture:Texture2D
@export var ammo_type:GunData.AmmoType

## only included if the pickup is a gun
@export var gun_data:GunData

enum Type{
	NULL, GUN, AMMO, HEALTH, OTHER_STUFF
}

enum Subtype{
	NULL, PISTOL, MACHINE_GUN, BULLETS,
}
