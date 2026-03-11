@abstract
extends Resource
class_name PickupData

@export var name:String
@export var type:Type
@export var texture:Texture2D

enum Type{
	NULL, GUN, AMMO, HEALTH, OTHER_STUFF
}
