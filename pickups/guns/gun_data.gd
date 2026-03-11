@abstract
extends Resource
class_name GunData

@export var name:String
@export var projectile:PackedScene
@export var pickup_sprite:Texture2D
@export var ui_sprite_frames:SpriteFrames
## This is the transform value where the sprite 
## frames are in the correct spot
@export var ui_transform_position:Vector2
@export var ui_scale:float = 1.0
@export var ammo_type:AmmoType
@export_range(0.1,15,.1,"suffix:shots/sec") var fire_rate:float
@export var type:Inventory.GunType
@export var reload:Vector2
var ready:bool = true

enum AmmoType{
	NULL, RAM, CREDITS, LINK, VIRUSES
}

@abstract func shoot(player:Player)
