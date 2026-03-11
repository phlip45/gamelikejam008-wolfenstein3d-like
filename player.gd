extends Actor
class_name Player

@export var inventory:Inventory
@onready var ui: CanvasLayer = $UI
var flesh:Flesh = Flesh.create(Vector2i(100,100))


@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var gun_cloaca: Node3D = $Head/Camera3D/GunCloaca

@export var sprint = 1.0
@export var sprint_max = 3.0
const speed = 5.0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO

var gun_state:GunState = GunState.READY

enum GunState{
	NULL, CHANGING_WEAPON, READY
}

func _init() -> void:
	Global.player = self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var amount_to_add =  event.relative if event.relative.length() > 0.0 else Vector2.ZERO
		mouse_move += amount_to_add * Global.Settings.mouse_sensitivity * .003
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _process(delta: float) -> void:
	handle_weapon(delta)
	move(delta)
	mouse_look(delta)
	
func mouse_look(_delta:float):
		camera_3d.rotation.y -= mouse_move.x
		camera_3d.rotation.x -= mouse_move.y
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, -PI/3, PI/3)
		mouse_move = Vector2.ZERO

func move(_delta:float):
	var input_dir:Vector2 = Input.get_vector("left", "right", "forward", "back")
	var vert_dir:float = Input.get_axis("down","up")
	var direction:Vector3 = (camera_3d.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var horiz_speed:Vector2 = Vector2(direction.x, direction.z).normalized()
	if direction or vert_dir:
		velocity.x = horiz_speed.x * speed * sprint
		#velocity.y = vert_dir * speed
		velocity.z = horiz_speed.y * speed * sprint
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = 0
		velocity.z = move_toward(velocity.z, 0, speed)
	if input_dir.length_squared() > 0 and Input.is_action_pressed("shift"):
		velocity *= sprint_max
	move_and_slide()

func handle_weapon(delta:float):
	var gun = inventory.current_weapon
	if gun:
		gun.reload.x -= delta
		if !Input.is_action_pressed("click"):return
		if gun.reload.x > 0 or not gun.ready: return
		pull_trigger(gun, delta)

func pull_trigger(gun:GunData,_delta:float):
	if gun_state != GunState.READY: return
	if gun.reload.x < 0:
		if gun.ready:
			inventory.pull_trigger(self)
			gun.reload.x = gun.reload.y
