extends Node3D
class_name Door

@export var locked:bool = false
@onready var door: MeshInstance3D = $DoorComplete/Skeleton3D/Door
@onready var activate_area: Interactable = $ActivateArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const PORTAL_PURPLE_SHADER:String = "uid://mys0q8jdo01m"
const PORTAL_RED_SHADER:String = "uid://di7k1hu1ix4gf"
var purple_shader:Material
var red_shader:Material
var state:State = State.CLOSED
enum State{
	OPEN, CLOSED
}

func _ready() -> void:
	if activate_area.toggled and activate_area.toggleable:
		animation_player.play("interact")
	purple_shader = await Global.load_resource(PORTAL_PURPLE_SHADER)
	red_shader = await Global.load_resource(PORTAL_RED_SHADER)
	if locked:
		door.mesh.surface_set_material(1,red_shader)
	else:
		door.mesh.surface_set_material(1,purple_shader)

func unlock():
	locked = false
	door.mesh.surface_set_material(1,purple_shader)

func lock():
	door.mesh.surface_set_material(1,red_shader)
	locked = true

func open(override:bool = false):
	print("Opening Door")
	if state == State.OPEN: return
	if locked and !override:
		activate_area.toggled = false
		return
	state = State.OPEN
	animation_player.play("interact")
	
func close(override:bool = false):
	print("Closing Door")
	if state == State.CLOSED: return
	if locked and !override: 
		activate_area.toggled = true
		return
	state = State.CLOSED
	animation_player.play_backwards("interact")

func open_briefly(amount_of_time_to_open:float = 5):
	var tween:Tween = create_tween()
	tween.tween_callback(open.bind(true))
	tween.tween_interval(amount_of_time_to_open)
	tween.tween_callback(close.bind(true))
