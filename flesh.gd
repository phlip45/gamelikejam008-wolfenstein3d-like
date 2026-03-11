extends RefCounted
class_name Flesh

var health:Vector2i

signal damaged(amount:int)
signal died

static func create(_health:Vector2i)-> Flesh:
	var flesh:Flesh = Flesh.new()
	flesh.health = _health
	return flesh

func damage(amount:int):
	health.x -= amount
	if health.x <= 0:
		died.emit()
		return
	damaged.emit(amount)

func heal(amount:int):
	health.x = min(health.x + amount, health.y)
