extends CharacterBody3D

@export var sprint = 1.0
@export var sprint_max = 3.0
const speed = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera_3d: Camera3D = $Head/Camera3D
var mouse_move:Vector2 = Vector2.ZERO

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
	var prior_global_postion:Vector3 = global_position
	if input_dir.length_squared() > 0 and Input.is_action_pressed("shift"):
		velocity *= sprint_max
	move_and_slide()
