extends RefCounted
class_name Damage
var amount:int
var type:Type

enum Type{
	NULL,
	KILLER,
	DECODER,
	FRACTER
}

static func create(_amount:int, _type:Type) -> Damage:
	var damage:Damage = Damage.new()
	damage.amount = _amount
	damage.type = _type
	return damage
