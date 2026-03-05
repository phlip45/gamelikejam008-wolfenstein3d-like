extends Resource
class_name GunData

@export var name:String
@export var projectile:PackedScene
@export var world_sprite:Texture2D
@export var ammo_type:AmmoType
@export_range(0.1,15,.1,"suffix:shots/sec") var fire_rate:float
@export var reload_speed:float

enum AmmoType{
	NULL, RAM, CREDITS, LINK, VIRUSES
}

## Might change later to GunSpriteUI type that has the info needed for the
## UI to use.
@export var UI_sprite:Texture2D
