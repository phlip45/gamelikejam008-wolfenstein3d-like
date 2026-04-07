extends Activateable
class_name Oscillator

@export var active:bool = false
@export var how_often:float = 1
var time_til_tic:float

signal oscillated(new_value:bool)

func _ready():
	time_til_tic = how_often
	
func _process(delta: float) -> void:
	time_til_tic -= delta
	if time_til_tic <= 0:
		active = !active
		time_til_tic = how_often
		oscillated.emit(active)
		active_changed.emit()
