extends Brain
class_name HorseBrain

@export var name:String
@export var ranged_attack_fire_frame:int
@export var melee_attack_fire_frame:int
var awake:bool = false
var wait:Vector2 = Vector2(2,2)
var state:State
var target:Actor
var target_position:Vector3
var target_lock_time:Vector2 = Vector2(10,10)
var update_path_time:Vector2 = Vector2(0,1)

enum State{
	NULL,
	IDLE,
	MOVING,
	RANGED_ATTACK,
	MELEE_ATTACK,
	DYING,
	HURT,
}

var state_process:Dictionary[State,Callable] = {
	State.IDLE: _process_idle,
	State.MOVING: _process_moving,
	State.RANGED_ATTACK: _process_ranged_attack,
	State.MELEE_ATTACK: _process_melee_attack,
	State.DYING: _process_dying,
	State.HURT: _process_hurt,
}

func setup(_enemy:Enemy) -> void:
	enemy = _enemy
	change_state(State.IDLE)
	enemy.sprite.animation_finished.connect(_on_anim_finished)
	enemy.sprite.animation_looped.connect(_on_anim_finished)
	enemy.flinched.connect(flinch)

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

func _process_ranged_attack(_delta:float):
	pass

func _process_melee_attack(_delta:float):
	pass

func _process_dying(_delta:float):
	pass

func _process_hurt(_delta:float):
	pass

func flinch():
	print("Flinch")
	change_state(State.HURT)
	enemy.sprite.play("Hurt")
	var back_to_idle:Callable = func():
		enemy.sprite.animation = "Idle"
		change_state(State.IDLE)
	if !enemy.sprite.animation_finished.is_connected(back_to_idle):
		enemy.sprite.animation_finished.connect(back_to_idle, CONNECT_ONE_SHOT)
		

func _on_anim_finished():
	wait.x = wait.y

func change_state(_state:State):
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
