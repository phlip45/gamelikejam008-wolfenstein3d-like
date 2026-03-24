extends Actor
class_name Player

@export var inventory:Inventory
@onready var ui: CanvasLayer = $UI
@export var ray_cast_3d: RayCast3D
@export var starting_health: int
@export var max_health:int
var flesh:Flesh = Flesh.create(Vector2i(100,200), Flesh.Type.PLAYER)

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var gun_cloaca: Node3D = $Head/Camera3D/GunCloaca

@export var sprint = 1.0
@export var sprint_max = 3.0
const speed = 5.0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO

var gun_state:GunState = GunState.READY

var interactables_nearby:Array[Interactable]

enum GunState{
	NULL, CHANGING_WEAPON, READY
}

func _init() -> void:
	Global.player = self

func _ready() -> void:
	flesh.damaged.connect(on_damage)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var amount_to_add =  event.relative if event.relative.length() > 0.0 else Vector2.ZERO
		mouse_move += amount_to_add * Global.Settings.mouse_sensitivity * .003
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func damage(_damage:Damage):
	flesh.damage(_damage)

func _process(delta: float) -> void:
	handle_weapon(delta)
	interact(delta)
	switch_weapons(delta)
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
	if 	!Global.ui.gun_sprite.is_playing() or\
		Global.ui.gun_sprite.animation == "Idle" or\
		Global.ui.gun_sprite.animation == "Move":
		if velocity.length() < 1:
			if Global.ui.gun_sprite.sprite_frames.has_animation("Idle") and\
				Global.ui.gun_sprite.animation != "Idle":
				Global.ui.play_gun_anim("Idle")
		else:
			if Global.ui.gun_sprite.sprite_frames.has_animation("Move") and\
				Global.ui.gun_sprite.animation != "Move":
				
				Global.ui.play_gun_anim("Move")
			elif !Global.ui.gun_sprite.sprite_frames.has_animation("Move") and\
				Global.ui.gun_sprite.sprite_frames.has_animation("Idle") and\
				Global.ui.gun_sprite.animation != "Idle":
				Global.ui.play_gun_anim("Idle")
	move_and_slide()

func interact(_delta:float):
	if !Input.is_action_just_pressed("use"): return
	print(interactables_nearby)
	var interactable:Interactable = closest_interactable()
	if !interactable: return
	interactable.interact()

func switch_weapons(_delta:float):
	var switch_to:int
	if Input.is_action_just_pressed("1"):
		switch_to = 1
	if Input.is_action_just_pressed("2"):
		switch_to = 2
	if Input.is_action_just_pressed("3"):
		switch_to = 3
	if switch_to == 0: return
	inventory.switch_weapons_by_number(switch_to as Inventory.GunType)

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

func closest_interactable() -> Interactable:
	if interactables_nearby.size() == 0: return null
	var _closest_interactable:Interactable = interactables_nearby[0]
	var distance:float = global_position.distance_squared_to(_closest_interactable.global_position)
	for interactable in interactables_nearby:
		var new_distance:float = global_position.distance_squared_to(interactable.global_position)
		if new_distance < distance:
			distance = new_distance
			_closest_interactable = interactable
	return _closest_interactable

func _on_interactable_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("interactable"):
		var interactable = area as Interactable
		interactables_nearby.append(interactable)
		interactable.tree_exiting.connect(func():
			interactables_nearby.erase(interactable)
			,CONNECT_ONE_SHOT)

func _on_interactable_detector_area_exited(area: Area3D) -> void:
	var interactable = area as Interactable
	interactables_nearby.erase(interactable)

func on_damage(_unused:float):
	ui.flash_damage()
