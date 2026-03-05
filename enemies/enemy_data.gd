extends Resource
class_name EnemyData

@export var name:String
@export_range(0,10,.02,"suffix:rad/sec") var turn_speed:float = 3
@export_range(0,30,.02,"suffix:m/sec") var speed:float = 3
@export var state_machine:EnemyStateMachine
@export var animation_states:Dictionary[String,String]
@export var animation_sprite_frames:Dictionary[Direction, SpriteFrames] = {
	Direction.FORWARD:null,
	Direction.FORWARD_LEFT:null,
	Direction.LEFT:null,
	Direction.BACK_LEFT:null,
	Direction.BACK:null,
	Direction.BACK_RIGHT:null,
	Direction.RIGHT:null,
	Direction.FORWARD_RIGHT:null,
}

enum Direction{
	NULL,
	FORWARD,
	FORWARD_LEFT,
	LEFT,
	BACK_LEFT,
	BACK,
	BACK_RIGHT,
	RIGHT,
	FORWARD_RIGHT,
}
