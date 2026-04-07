extends Actor
class_name Player

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var inventory:Inventory
@onready var ui: UI = $UI
@export var ray_cast_3d: RayCast3D
@export var starting_health: int
@export var max_health:int
var flesh:Flesh = Flesh.create(Vector2i(100,200), Flesh.Type.PLAYER)
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var head: Node3D
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var gun_cloaca: Node3D = $Head/Camera3D/GunCloaca

@export var sprint = 1.0
@export var sprint_max = 3.0
const speed = 5.0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
var gun_state:GunState = GunState.READY
var interactables_nearby:Array[Interactable]
var state:State = State.ALIVE
var death_time:float = 2.0

var sounds:Dictionary[SoundName, AudioStream]

enum SoundName{
	death,
	hurt,
	buzzsaw_shoot,
	chop,
	gun_shoot,
	pickup,
	button_press,
	exit_unlocked,
}

enum State{
	NULL, ALIVE, DEAD
}

enum GunState{
	NULL, CHANGING_WEAPON, READY
}

func _init() -> void:
	Global.player = self

func _ready() -> void:
	sounds[SoundName.death] = await Global.load_resource("res://sound/sfx/death.mp3")
	sounds[SoundName.hurt] = await Global.load_resource("res://sound/sfx/player_hurt.mp3")
	sounds[SoundName.buzzsaw_shoot] = await Global.load_resource("res://sound/sfx/buzzsaw_shoot.mp3")
	sounds[SoundName.chop] = await Global.load_resource("res://sound/sfx/chop.mp3")
	sounds[SoundName.gun_shoot] = await Global.load_resource("res://sound/sfx/gun_shoot.mp3")
	sounds[SoundName.pickup] = await Global.load_resource("res://sound/sfx/pickup.mp3")
	sounds[SoundName.button_press] = await Global.load_resource("res://sound/sfx/button_press.mp3")
	sounds[SoundName.exit_unlocked] = await Global.load_resource("res://sound/sfx/exit_unlocked.mp3")
	flesh.died.connect(on_death)
	flesh.damaged.connect(on_damage)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("tab") and Engine.time_scale > 0:
		if inventory.current_weapon:
			inventory.current_weapon.reload.x = 2
		var options:Options = load("res://assets/UI/options.tscn").instantiate()
		Engine.time_scale = 0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		options.tree_exiting.connect(func():
			Engine.time_scale = 1
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		)
		ui.add_child(options)
	if event is InputEventMouseMotion and Engine.time_scale > 0:
		var amount_to_add =  event.relative if event.relative.length() > 0.0 else Vector2.ZERO
		mouse_move += amount_to_add * Global.Settings.mouse_sensitivity * .003
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click") and Engine.time_scale > 0:
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func damage(_damage:Damage):
	flesh.damage(_damage)

func _process(delta: float) -> void:
	if state == State.DEAD:
		_process_dead(delta)
		return
	handle_weapon(delta)
	interact(delta)
	switch_weapons(delta)
	move(delta)
	mouse_look(delta)

func _process_dead(delta):
	death_time -= delta
	if death_time > 0:
		return
	if (Input.is_action_just_pressed("use") or
		Input.is_action_just_pressed("click")):
		Global.restart_level()

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
		switch_to = 3
	if Input.is_action_just_pressed("3"):
		switch_to = 2
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
	play_sound(SoundName.hurt)
	ui.flash_damage()

func on_death():
	state = State.DEAD
	ui.display_death()
	collision_shape_3d.disabled = true
	play_sound(SoundName.death)
	var tween:Tween = create_tween()
	tween.tween_property(head,"position", Vector3(0,.2,0), 1.0)

func play_sound(soundname:SoundName):
	audio_stream_player_3d.pitch_scale = randf_range(.9,1.1)
	audio_stream_player_3d.stream = sounds[soundname]
	audio_stream_player_3d.play()
