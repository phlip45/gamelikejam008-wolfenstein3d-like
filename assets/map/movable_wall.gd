extends Node3D
class_name MovableWall

@export var distance:float = 5.0
@export var duration:float = 1.0
@export var move_up_instead:bool = false
@export var one_shot:bool = false
var locked:bool = false
var active:bool = false
var moved:bool = false
@onready var static_body_3d: StaticBody3D = $StaticBody3D

func activate():
	if locked: return
	if moved:
		move_backwards()
	else:
		move()

func move():
	if active: return
	active = true
	static_body_3d.position = Vector3.ZERO
	var tween:Tween = create_tween()
	tween.tween_property(
		static_body_3d,
		"position", 
		Vector3(0,0,-distance), 
		duration)
	tween.tween_callback(func(): 
		moved = true
		active = false
		if one_shot:
			locked = true
	)

func move_backwards():
	if active: return
	active = true
	static_body_3d.position = Vector3(0,0,-distance)
	var tween:Tween = create_tween()
	tween.tween_property(
		static_body_3d,
		"position", 
		Vector3(0,0,0),
		duration)
	tween.tween_callback(func(): 
		moved = false
		active = false
		if one_shot:
			locked = true
	)
