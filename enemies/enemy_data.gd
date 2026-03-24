extends Resource
class_name EnemyData

@export var name:String
@export_range(0,10,.02,"suffix:rad/sec") var turn_speed:float = 3
@export_range(0,30,.02,"suffix:m/sec") var speed:float = 3
## x is starting and y is max
@export var health:Vector2i
@export_range(0, 200, 1, "suffix:percent") var poise:float = 10
@export_range(0,TAU,.01,"suffix:rads") var field_of_view:float
@export var scale_override:float = 1.0
@export var type:Flesh.Type
@export var brain:Brain
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
