extends Node3D

@onready var menu: CanvasLayer = $Menu
@onready var color_rect: ColorRect = $Menu/Control/ColorRect
var viewport_size:Rect2
var viewport:Viewport
var time:float = 0
func _on_play_pressed() -> void:
	Global.load_new_player()
	Global.scene_changer.change_scene(Level.level_name_to_file[Level.LevelName.BALLISTA])

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	viewport = get_viewport()
	set_viewport_size()
	viewport.size_changed.connect(set_viewport_size)

func set_viewport_size():
	viewport_size = viewport.get_visible_rect()

func _process(delta: float) -> void:
	time += delta
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	color_rect.modulate = Color(mouse_pos.x/viewport_size.size.x, mouse_pos.y/viewport_size.size.y, sin(time))

func _on_options_pressed() -> void:
	var options:PackedScene = load("res://assets/UI/options.tscn")
	var newmenu = options.instantiate()
	menu.add_child(newmenu)

func _on_portal_mouse_entered() -> void:
	Input.warp_mouse($Menu/Control/Marker2D.position * 4)
