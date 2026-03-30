@tool
extends Node3D
class_name Exit

@export var animated_sprite_3d: AnimatedSprite3D
@onready var walk_on: WalkOnTrigger = $WalkOn

@export var active:bool = false:
	set(value):
		active = value
		update_sprite()

func _ready():
	if !Engine.is_editor_hint():
		Global.level.kessleroid_killed.connect(check_to_open)
	update_sprite()

func update_sprite():
	if active:
		animated_sprite_3d.animation = "Active"
	else:
		animated_sprite_3d.animation = "Inactive"
	animated_sprite_3d.play()

func _on_walk_on_trigger() -> void:
	if active:
		exit_level()

func exit_level():
	Global.finish_level()

func activate():
	if !active:
		active = true

func deactivate():
	if active:
		active = false

func check_to_open(kessleroids_left:int):
	print("Exit_opening in : ", kessleroids_left)
	if kessleroids_left <= 0:
		activate()
	if kessleroids_left > 0:
		deactivate()
	
