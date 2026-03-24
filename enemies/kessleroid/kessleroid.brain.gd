extends Brain
class_name KessleroidBrain

@export var name:String
var state:State

enum State{
	NULL,
	IDLE,
	HURT,
}

var anim_names:Dictionary[State,String] = {
	State.NULL: "Null" ,
	State.IDLE: "Idle" ,
	State.HURT: "Hurt" ,
}

var state_process:Dictionary[State,Callable] = {
	State.IDLE: _process_idle,
	State.HURT: _process_hurt,
}
func setup(_enemy:Enemy) -> void:
	enemy = _enemy
	change_state(State.IDLE)
	enemy.sprite.animation_finished.connect(_on_anim_finished)
	enemy.sprite.animation_looped.connect(_on_anim_finished)
	enemy.flesh.damaged.connect(on_damaged)
	enemy.flesh.died.connect(on_death)

func process(delta:float):
	if state == State.NULL: return
	state_process[state].call(delta)

func _process_idle(_delta:float):
	pass

func _process_hurt(_delta:float):
	pass

func on_damaged(amount:int):
	print("Damaged: ", amount)
	if enemy.collision_shape_3d.disabled: return
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate",Color.RED,.2)
	tween.tween_property(enemy.sprite,"modulate",Color.WHITE,.1)
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
	Explosion.spawn(enemy.global_position + Vector3(0,1.5,0), 4.0)
	var tween:Tween = enemy.create_tween()
	tween.tween_property(enemy.sprite,"modulate", Color.TRANSPARENT, .5)
	tween.tween_callback(enemy.die)

func _on_anim_finished():
	pass

func change_state(_state:State):
	enemy.debug_label.text = State.find_key(_state)
	enemy.debug_label.text += " " +enemy.sprite.animation
	enemy.sprite.play(anim_names[_state])
	state = _state
