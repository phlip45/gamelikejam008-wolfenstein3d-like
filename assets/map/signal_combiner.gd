extends Activateable

@export var activateables_to_combine:Array[Activateable]
var active:bool

signal all_active

func _ready() -> void:
	for actable:Activateable in activateables_to_combine:
		actable.active_changed.connect(on_actables_active_changed)

func check_if_active() -> bool:
	var _active:bool = true
	for actable:Activateable in activateables_to_combine:
		if !actable.active:
			_active = false
	return _active

func on_actables_active_changed():
	var old_active:bool = active
	active = check_if_active()
	if active != old_active:
		active_changed.emit()
		if active:
			all_active.emit()
