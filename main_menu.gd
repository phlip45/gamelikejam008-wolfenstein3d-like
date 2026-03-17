extends Node3D

@onready var color_rect: ColorRect = $Menu/Control/ColorRect
var viewport_size:Rect2
var viewport:Viewport
var time:float = 0
func _on_play_pressed() -> void:
	Global.scene_changer.change_scene("res://level_1.tscn")

func _ready() -> void:
	viewport = get_viewport()
	set_viewport_size()
	viewport.size_changed.connect(set_viewport_size)

func set_viewport_size():
	viewport_size = viewport.get_visible_rect()

func _process(delta: float) -> void:
	time += delta
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	color_rect.modulate = Color(mouse_pos.x/viewport_size.size.x, mouse_pos.y/viewport_size.size.y, sin(time))
	
