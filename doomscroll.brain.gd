extends Brain
class_name DoomscrollBrain

@export var name:String
@export var wait:Vector2 = Vector2(2,4)
## Further than this range and the enemy attacks with their projectile.
## Less than this but more than melee range and the enemy will randomly
## decide to try and close the gap or shoot a missile.
@export var missile_range:float
var awake:bool = false
var state:State
var target:Actor
var target_position:Vector3
var target_lock_time:Vector2 = Vector2(10,10)
var update_path_time:Vector2 = Vector2(0,1)
var aggression:float = 20.0

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
## TODO this part needs fixed
var bullet_path:String = "res://assets/guns/big_bullet.tscn"
var bullet_scene:PackedScene
func setup(_enemy:Enemy) -> void:
	#bullet_scene = await Global.load_scene(bullet_path)
	enemy = _enemy
	change_state(State.IDLE)
	enemy.sprite.animation_finished.connect(_on_anim_finished)
	enemy.sprite.animation_looped.connect(_on_anim_finished)
	enemy.flesh.damaged.connect(on_damaged)
	enemy.flesh.died.connect(on_death)

func process(delta:float):
	target_lock_time.x -= delta
	if state == State.NULL: return
	state_process[state].call(delta)

func _process_idle(delta:float):
	wait.x -= delta
	if wait.x <= 0:
		wait.x = wait.y
	if can_see_player():
		target = Global.player
		update_path_time.x = update_path_time.y
		enemy.nav_agent.target_position = Global.player.global_position
		change_state(State.MOVING)

func _process_moving(delta:float):
	update_path_time.x -= delta
	move_toward_target()
	wait.x -= delta
	if wait.x <= 0:
		wait.x = wait.y
	if update_path_time.x > 0: return
	update_path_time.x = update_path_time.y
	enemy.nav_agent.target_position = target.global_position
	#var path:Vector3 = enemy.nav_agent.get_next_path_position()
	move_toward_target()

func _process_attack(_delta:float):
	pass

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

func decide_state_by_range():
	var distance:float = enemy.global_position.distance_to(target.global_position)
	if distance <= missile_range:
		#too close, get further, but sometimes attack anyways
		pass
	else:
		#ranged
		pass

func on_damaged(amount:int):
	if state == State.DYING: return
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate",Color.RED,.2)
	tween.tween_property(enemy.sprite,"modulate",Color.WHITE,.1)
	if enemy.should_flinch(amount):
		change_state(State.HURT)
		enemy.sprite.play("Hurt")
		var back_to_idle:Callable = func():
			enemy.sprite.animation = "Idle"
			change_state(State.IDLE)
		if !enemy.sprite.animation_finished.is_connected(back_to_idle):
			enemy.sprite.animation_finished.connect(back_to_idle, CONNECT_ONE_SHOT)

func on_death():
	enemy.collision_shape_3d.disabled = true
	change_state(State.DYING)
	enemy.sprite.play("Death")
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate",Color.TRANSPARENT,0.9)
	enemy.sprite.animation_finished.connect(enemy.die)

func _on_anim_finished():
	wait.x = wait.y

func change_state(_state:State):
	print(State.find_key(_state))
	enemy.debug_label.text = State.find_key(_state)
	state = _state

func move_toward_target() -> bool:
	if enemy.global_position.distance_to(target_position) > 1:
		var next_location = enemy.nav_agent.get_next_path_position()
		if !is_colinear_with_up(enemy.global_position,next_location) and !enemy.global_position.is_equal_approx(next_location):
			var prev_rot:Vector3 = enemy.rotation
			enemy.look_at(next_location)
			var target_rotation:Vector3 = shortest_rotation_path(prev_rot,enemy.rotation)
			enemy.rotation = prev_rot.move_toward(target_rotation,.1)
			
		enemy.rotation.x = 0
		enemy.rotation.z = 0
		var new_velocity = (next_location - enemy.global_position).normalized() * enemy.speed
		enemy.velocity = enemy.velocity.move_toward(new_velocity,.25)
		enemy.move_and_slide()
		return false
	else:
		return true
