extends Brain
class_name DoomscrollBrain

@export var name:String
@export var wait:Vector2 = Vector2(3,3)
## Further than this range and the enemy attacks with their projectile.
## Less than this but more than melee range and the enemy will randomly
## decide to try and close the gap or shoot a missile.
@export var missile_range:float
@export var missile_activate_frame:int = 17
var awake:bool = false
var state:State
var target:Actor
var move_target:Vector3
var target_lock_time:Vector2 = Vector2(10,10)
var update_path_time:Vector2 = Vector2(0,1)
var aggression:float = 20.0
@export_file_path("*.projectile.tscn") var ranged_projectile_path:String
var ranged_projectile_scene:PackedScene
var last_decision:State
@export var global_attack_cooldown:Vector2 = Vector2(.4,.4)

enum State{
	NULL,
	IDLE,
	MOVING,
	RANGED_ATTACK,
	DYING,
	HURT,
}

var anim_names:Dictionary[State,String] = {
	State.NULL: "Null" , # This will throw error which is good
	State.IDLE: "Idle" ,
	State.MOVING: "Idle" ,
	State.RANGED_ATTACK: "Attack" ,
	State.DYING: "Death" ,
	State.HURT: "Hurt" ,
}

var state_process:Dictionary[State,Callable] = {
	State.IDLE: _process_idle,
	State.MOVING: _process_moving,
	State.RANGED_ATTACK: _process_attack,
	State.DYING: _process_dying,
	State.HURT: _process_hurt,
}

func setup(_enemy:Enemy) -> void:
	ranged_projectile_scene = await Global.load_scene(ranged_projectile_path)
	enemy = _enemy
	change_state(State.IDLE)
	enemy.projectile_cloaca.position = projectile_cloaca_position
	enemy.sprite.animation_finished.connect(_on_anim_finished)
	enemy.sprite.animation_looped.connect(_on_anim_finished)
	enemy.flesh.damaged.connect(on_damaged)
	enemy.flesh.died.connect(on_death)
	enemy.sprite.frame_changed.connect(_on_sprite_frame_changed)

func process(delta:float):
	wait.x -= delta
	global_attack_cooldown.x -= delta
	target_lock_time.x -= delta
	if state == State.NULL: return
	state_process[state].call(delta)

func _process_idle(delta:float):
	if wait.x <= 0:
		wait.x = wait.y
		#decide_action_by_range()
		return
	if can_see_player():
		target = Global.player
		update_path_time.x = update_path_time.y
		change_state(State.MOVING)

func _process_moving(delta:float):
	update_path_time.x -= delta
	move_toward_target()
	if wait.x <= 0:
		wait.x = wait.y
		decide_action_by_range()
		return
	if enemy.global_position.distance_squared_to(enemy.nav_agent.get_final_position()) < 1.0:
		decide_action_by_range()

func _process_attack(_delta:float):
	rotate_toward_enemy()
	if !enemy.sprite.is_playing():
		decide_action_by_range()

func _process_dying(_delta:float):
	pass

func _process_hurt(_delta:float):
	pass

func get_target():
	if !target:
		if can_see_player():
			target = Global.player
		else: 
			change_state(State.IDLE)
			return

func decide_action_by_range():
	if last_decision == State.RANGED_ATTACK:
		run_away()
		return
	var distance:float = enemy.global_position.distance_to(target.global_position)
	if distance <= missile_range:
		if randf() < .4:
			shoot()
			return
		run_away()
	else:
		if randf() < .6:
			shoot()
			return
		run_away()

func on_damaged(amount:int):
	if state == State.DYING: return
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate",Color.RED,.2)
	tween.tween_property(enemy.sprite,"modulate",Color.WHITE,.1)
	if !target:
		target = Global.player
	if enemy.should_flinch(amount):
		change_state(State.HURT)
		enemy.sprite.play("Hurt")
		if !enemy.sprite.animation_finished.is_connected(back_to_idle):
			enemy.sprite.animation_finished.connect(back_to_idle, CONNECT_ONE_SHOT)

func back_to_idle():
	enemy.sprite.animation = anim_names[State.IDLE]
	change_state(State.IDLE)
	
func on_death():
	enemy.collision_shape_3d.disabled = true
	change_state(State.DYING)
	enemy.sprite.play("Death")
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate",Color.TRANSPARENT,0.9)
	enemy.sprite.animation_finished.connect(enemy.die)

func _on_anim_finished():
	#wait.x = wait.y
	pass

func change_state(_state:State):
	print(State.find_key(_state))
	enemy.debug_label.text = State.find_key(_state)
	state = _state

func move_toward_target() -> void:
	match(state):
		State.IDLE:
			pass
		State.MOVING:
			var next_location = enemy.nav_agent.get_next_path_position()
			rotate_toward_target()
			next_location.y = 0
			var new_velocity:Vector3 = (next_location - enemy.global_position).normalized() * enemy.speed
			enemy.velocity = enemy.velocity.move_toward(new_velocity,.25)
			enemy.move_and_slide()
		State.RANGED_ATTACK:
			rotate_toward_target()
		_:
			return

func _on_sprite_frame_changed():
	if enemy.sprite.frame == missile_activate_frame and state == State.RANGED_ATTACK:
		spawn_missile()

func shoot():
	last_decision = State.RANGED_ATTACK
	change_state(State.RANGED_ATTACK)
	enemy.sprite.play(anim_names[State.RANGED_ATTACK])

func spawn_missile():
	if global_attack_cooldown.x > 0: return
	var attack:PopupProjectile = ranged_projectile_scene.instantiate() as PopupProjectile
	enemy.add_child(attack)
	attack.setup(enemy.projectile_cloaca.global_position,enemy.rotation, enemy)

func run_away():
	last_decision = State.MOVING
	move_target = get_run_position()
	enemy.nav_agent.target_position = move_target
	print("Running Away: ",move_target)
	change_state(State.MOVING)
	
func get_run_position() -> Vector3:
	var direction:Vector3 = (enemy.global_position - Global.player.global_position).normalized()
	var angle_rad:float = randf_range(-PI/4, PI/4)
	var rotated_dir:Vector3 = direction.rotated(Vector3.UP, angle_rad)
	var result:Vector3 = Global.player.global_position + rotated_dir * randf_range(4.0,6.0)
	return result

	
func rotate_toward_enemy() -> void:
	var prev_rot:Vector3 = enemy.rotation
	enemy.look_at(target.global_position)
	var target_rotation:Vector3 = shortest_rotation_path(prev_rot,enemy.rotation)
	enemy.rotation = prev_rot.move_toward(target_rotation,.1)
