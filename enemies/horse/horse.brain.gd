extends Brain
class_name HorseBrain

@export var name:String
@export var decide_time:Vector2 = Vector2(.5,1.0)
## Less than this and the enemy attacks melee. More than than this
## but less than missile_range and the enemy will randomly decide to
## try and close the gap or shoot a missile
@export var melee_range:float
@export var melee_activate_frame:int = 9
## Further than this range and the enemy attacks with their projectile.
## Less than this but more than melee range and the enemy will randomly
## decide to try and close the gap or shoot a missile.
@export var missile_range:float
@export var missile_activate_frame:int = 17
@export var global_attack_cooldown:Vector2 = Vector2(.4,.4)

@export_file_path() var melee_projectile_path:String
var melee_projectile_scene:PackedScene
@export_file_path var ranged_projectile_path:String
var ranged_projectile_scene:PackedScene

var awake:bool = false
var state:State
var target:Actor
var stationary:bool = false
var move_target:Vector3
var update_path_time:Vector2 = Vector2(0,1)
var aggression:float = 20.0

enum State{
	NULL,
	IDLE,
	MOVING,
	RANGED_ATTACK,
	MELEE_ATTACK,
	DYING,
	HURT,
}

var anim_names:Dictionary[State,String] = {
	State.NULL: "Null" ,
	State.IDLE: "Idle" ,
	State.MOVING: "Idle" ,
	State.RANGED_ATTACK: "RangedAttack" ,
	State.MELEE_ATTACK: "MeleeAttack" ,
	State.DYING: "Death" ,
	State.HURT: "Hurt" ,
}

var state_process:Dictionary[State,Callable] = {
	State.IDLE: _process_idle,
	State.MOVING: _process_moving,
	State.RANGED_ATTACK: _process_ranged_attack,
	State.MELEE_ATTACK: _process_melee_attack,
	State.DYING: _process_dying,
	State.HURT: _process_hurt,
}
var bullet_path:String = "res://assets/guns/big_bullet.tscn"
var bullet_scene:PackedScene
func setup(_enemy:Enemy) -> void:
	bullet_scene = await Global.load_scene(bullet_path)
	melee_projectile_scene = await Global.load_scene(melee_projectile_path)
	ranged_projectile_scene = await Global.load_scene(ranged_projectile_path)
	enemy = _enemy
	stationary = enemy.stationary
	change_state(State.IDLE)
	enemy.projectile_cloaca.position = projectile_cloaca_position
	enemy.sprite.animation_finished.connect(_on_anim_finished)
	enemy.sprite.animation_looped.connect(_on_anim_finished)
	enemy.flesh.damaged.connect(on_damaged)
	enemy.flesh.died.connect(on_death)
	enemy.sprite.frame_changed.connect(_on_sprite_frame_changed)

func process(delta:float):
	global_attack_cooldown.x -= delta
	if state == State.NULL: return
	state_process[state].call(delta)

func _process_idle(_delta:float):
	if can_see_player() and !target:
		target = Global.player
	if target:
		update_path_time.x = update_path_time.y
		enemy.nav_agent.target_position = Global.player.global_position
		if stationary:
			shoot()
			return
		change_state(State.MOVING)

func _process_moving(delta:float):
	if stationary:
		_process_stationary_moving(delta)
		return
	update_path_time.x -= delta
	move_toward_target()
	decide_time.x -= delta
	if decide_time.x < 0:
		decide_time.x = decide_time.y
		decide_action_by_range()
	update_path()

func _process_stationary_moving(delta:float):
	stationary_rotate_toward_target()
	decide_time.x -= delta
	if decide_time.x < 0:
		decide_time.x = decide_time.y
		decide_action_by_range()

func _process_stationary_ranged_attack(_delta:float):
	stationary_rotate_toward_target()
	if !enemy.sprite.is_playing():
		change_state(State.IDLE)

func update_path():
	if update_path_time.x > 0: return
	update_path_time.x = update_path_time.y
	enemy.nav_agent.target_position = target.global_position
	#var path:Vector3 = enemy.nav_agent.get_next_path_position()

func _process_ranged_attack(delta:float):
	if stationary:
		_process_stationary_ranged_attack(delta)
		return
	rotate_toward_target()
	if !enemy.sprite.is_playing():
		change_state(State.IDLE)

func _process_melee_attack(_delta:float):
	rotate_toward_target()
	if !enemy.sprite.is_playing():
		change_state(State.IDLE)
	

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
	if !target: return
	var distance:float = enemy.global_position.distance_to(target.global_position)
	if stationary:
		shoot()
	if distance <= melee_range:
		melee()
	elif distance <= missile_range:
		#somewhere between able to melee and desired missile range.
		var shoot_chance:float = 1
		match Global.Settings.difficulty:
			Global.Settings.Difficulty.EASY:
				shoot_chance = .2
			Global.Settings.Difficulty.NORMAL:
				shoot_chance = .4
			Global.Settings.Difficulty.HARD:
				shoot_chance = .6
			Global.Settings.Difficulty.ULTRA:
				shoot_chance = .8
		if randf() < shoot_chance:
			shoot()
		else:
			change_state(State.MOVING)
	else:
		shoot()

func melee():
	enemy.play_sound(Enemy.SoundName.horse_melee)
	
	change_state(State.MELEE_ATTACK)
	enemy.sprite.play(anim_names[State.MELEE_ATTACK])
	

func spawn_melee_attack():
	var attack:MeleeProjectile = melee_projectile_scene.instantiate() as MeleeProjectile
	enemy.add_child(attack)
	attack.setup(enemy.global_position,enemy.rotation, enemy)

func shoot():
	change_state(State.RANGED_ATTACK)

	enemy.sprite.play(anim_names[State.RANGED_ATTACK])

func spawn_missile():
	if global_attack_cooldown.x > 0: return
	enemy.play_sound(Enemy.SoundName.horse_shoot)
	
	var attack:SnotBallProjectile = ranged_projectile_scene.instantiate() as SnotBallProjectile
	enemy.add_child(attack)
	attack.setup(enemy.projectile_cloaca.global_position,enemy.rotation, enemy)

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
	enemy.play_sound(Enemy.SoundName.horse_hurt)

func back_to_idle():
	shoot()
func on_death():
	enemy.collision_shape_3d.disabled = true
	enemy.play_sound(Enemy.SoundName.horse_die)
	change_state(State.DYING)
	enemy.sprite.play("Death")
	enemy.sprite.animation_finished.connect(enemy.die, CONNECT_ONE_SHOT)

func _on_anim_finished():
	pass

func change_state(_state:State):
	enemy.debug_label.text = State.find_key(_state)
	enemy.debug_label.text += " " +enemy.sprite.animation
	enemy.sprite.play(anim_names[_state])
	state = _state
	

func move_toward_target() -> bool:
	if enemy.global_position.distance_to(enemy.nav_agent.target_position) > 1:
		var next_location = enemy.nav_agent.get_next_path_position()
		rotate_toward_target()
		next_location.y = 0
		var new_velocity:Vector3 = (next_location - enemy.global_position).normalized() * enemy.speed
		enemy.velocity = enemy.velocity.move_toward(new_velocity,.25)
		enemy.move_and_slide()
		return false
	else:
		return true

func _on_sprite_frame_changed():
	if enemy.sprite.frame == melee_activate_frame and state == State.MELEE_ATTACK:
		print("Chopping")
		spawn_melee_attack()
	if enemy.sprite.frame == missile_activate_frame and state == State.RANGED_ATTACK:
		print("Shooting")
		spawn_missile()

func stationary_rotate_toward_target()-> void:
	if !is_colinear_with_up(enemy.global_position,target.global_position) and !enemy.global_position.is_equal_approx(target.global_position):
		var prev_rot:Vector3 = enemy.rotation
		enemy.look_at(target.global_position)
		var target_rotation:Vector3 = shortest_rotation_path(prev_rot,enemy.rotation)
		enemy.rotation = prev_rot.move_toward(target_rotation,.1)
