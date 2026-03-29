@abstract
extends Resource
class_name PickupData

@export var name:String
@export var type:Type
@export var sprite_scale:float = 1.0
@export var texture:Texture2D
@export var sprite_frames:SpriteFrames
@export var starting_anim:String = "Idle"

enum Type{
	NULL, GUN, AMMO, HEALTH, OTHER_STUFF
}
