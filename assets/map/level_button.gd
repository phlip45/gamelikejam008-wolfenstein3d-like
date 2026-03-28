@tool
extends Node3D
class_name LevelButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var one_shot:bool = false
@export var toggleable:bool = false:
	set(value):
		toggleable = value
		play_button_animation()
@export var active:bool = false:
	set(value):
		active = value
		play_button_animation()
var disabled:bool = false

signal pressed
signal toggled_on
signal toggled_off

func _ready() -> void:
	if active:
		animation_player.play("activate")

func interact():
	if disabled: return
	if animation_player.is_playing(): return
	if toggleable:
		active = !active
	else:
		active = true
	if one_shot:
		disabled = true

func play_button_animation():
	if !animation_player: 
		return
	if toggleable:
		if active:
			animation_player.play("activate")
			toggled_on.emit()
			await animation_player.animation_finished
		else:
			animation_player.play("deactivate")
			toggled_off.emit()
			await animation_player.animation_finished
	else:
		animation_player.play("press")
		pressed.emit()
		await animation_player.animation_finished
