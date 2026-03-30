@tool
extends Area3D
class_name Portal

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var active:bool = true:
	set(value):
		active = value
		update_portal()
@export var portal_endpoint:Node3D
@export var endpoint_only:bool
@export var cooldown:float = 2.0
var last_teleport:float = 0.0

func _ready() -> void:
	if active: enable()
	else: disable()

func toggle_active():
	active = !active

func enable():
	if active: return
	toggle_active()

func disable():
	if !active: return
	toggle_active()

func update_portal():
	visible = active
	if !collision_shape_3d: return
	collision_shape_3d.disabled = !active

func teleport(_actor:Node3D) -> void:
	if !active: return
	if _actor is not Actor:return
	var actor = _actor as Actor
	if endpoint_only: return
	if !portal_endpoint:return
	if is_on_cooldown(): return
	var end_pos:Vector3 = portal_endpoint.global_position
	end_pos.y = 0
	actor.global_position = end_pos
	last_teleport = Global.level.timer
	if portal_endpoint is Portal:
		(portal_endpoint as Portal).last_teleport = Global.level.timer

func is_on_cooldown() -> bool:
	if Global.level.timer <= last_teleport + cooldown:
		return true
	return false
