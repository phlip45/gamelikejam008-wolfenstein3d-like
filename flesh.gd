extends RefCounted
class_name Flesh

var health:Vector2i
var starting_health:int
var max_health:int
var type:Flesh.Type

enum Type{
	NULL,
	PLAYER,
	CODE_GATE,
	BARRIER,
	SENTRY,
}
signal damaged(amount:int)
signal died
signal health_changed(new_amount:int)

var weak_to:Dictionary[Damage.Type, Flesh.Type] = {
	Damage.Type.DECODER: Type.CODE_GATE,
	Damage.Type.FRACTER: Type.BARRIER,
	Damage.Type.KILLER: Type.SENTRY,
}

static func create(_health:Vector2i, _type:Type)-> Flesh:
	var flesh:Flesh = Flesh.new()
	flesh.type = _type
	flesh.health = _health
	flesh.max_health = _health.y
	flesh.starting_health = _health.x
	return flesh

func damage(_damage:Damage):
	if weak_to.has(_damage.type) and weak_to[_damage.type] != type:
		_damage.amount /= 4
		_damage.amount = max(1,_damage.amount)
	health.x -= _damage.amount
	if health.x <= 0:
		health_changed.emit(0)
		died.emit()
		return
	else:
		damaged.emit(_damage.amount)
		health_changed.emit(health.x)

func heal(amount:int, over_heal:bool = false):
	if !over_heal:
		if health.x > starting_health: return
		health.x = min(health.x + amount, starting_health)
	else:
		health.x = min(health.x + amount, health.y)
	health_changed.emit(health.x)

func is_hale():
	if health.x >= starting_health:
		return true
	return false
