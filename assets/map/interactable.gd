extends Area3D
class_name Interactable

@export var toggleable:bool
@export var starting_value:bool
@export var toggled:bool

signal used
signal on
signal off

func _ready() -> void:
	toggled = starting_value

func interact():
	print("Interacting")
	toggled = !toggled
	if toggleable and toggled:
		on.emit()
	elif toggleable and !toggled:
		off.emit()
	else:
		used.emit()
