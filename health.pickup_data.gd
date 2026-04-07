extends PickupData
class_name HealthPickupData

@export var amount:int
@export var overheal_allowed:bool = false

func heal(flesh:Flesh):
	flesh.heal(amount, overheal_allowed)
