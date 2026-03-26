extends Area3D
class_name Interactable

@export var toggleable:bool
@export var starting_value:bool
@export var animation_player: AnimationPlayer
var toggled:bool

func _ready() -> void:
	toggled = starting_value

func interact():
	if toggleable and toggled:
		animation_player.play_backwards("interact")
	else:
		animation_player.play("interact")
	toggled = !toggled
