extends Actor
class_name Enemy

@export_range(0,10,.02,"suffix:rad/sec") var turn_speed:float = 3
@export_range(0,30,.02,"suffix:m/sec") var speed:float = 3
@export var data:EnemyData
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var debug_label: Label3D = $DebugLabel
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
var brain:Brain
var flesh:Flesh


var camera:Camera3D
var animation_sprites:Dictionary[EnemyData.Direction, SpriteFrames]

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

signal damaged(amount:int)

func _ready() -> void:
	flesh = Flesh.create(data.health)
	brain = data.brain.duplicate()
	if !get_tree().debug_collisions_hint:
		debug_label.visible = false
	brain.setup(self)

func _process(delta: float) -> void:
	#rotation.y += delta
	brain.process(delta)
	set_sprite_facing(delta)

func set_sprite_facing(_delta:float):
	var vec_to_cam:Vector2 = get_vector_to_camera()
	vec_to_cam = vec_to_cam.rotated(rotation.y)
	var wedge_offset:float = PI /8.0 #have to move half a wedge to start
	var wedge_angle:float = PI / 4.0
	var ang:float = -vec_to_cam.angle() + wedge_offset
	if ang < 0.0:
		ang += TAU
	var dir:int = int(floor(ang / wedge_angle)) % 8
	match dir:
		0:
			set_sprite_dir(EnemyData.Direction.RIGHT)
		1:
			set_sprite_dir(EnemyData.Direction.FORWARD_RIGHT)
		2:
			set_sprite_dir(EnemyData.Direction.FORWARD)
		3:
			set_sprite_dir(EnemyData.Direction.FORWARD_LEFT)
		4:
			set_sprite_dir(EnemyData.Direction.LEFT)
		5:
			set_sprite_dir(EnemyData.Direction.BACK_LEFT)
		6:
			set_sprite_dir(EnemyData.Direction.BACK)
		7:
			set_sprite_dir(EnemyData.Direction.BACK_RIGHT)

func set_sprite_dir(dir:EnemyData.Direction):
	if sprite.sprite_frames == data.animation_sprite_frames[dir]:
		return
	if sprite.animation == "": return
	var frame:int = sprite.frame
	var anim_name:String = sprite.animation
	sprite.sprite_frames = data.animation_sprite_frames[dir]
	sprite.animation = anim_name
	sprite.play()
	sprite.frame = frame

func get_vector_to_camera() -> Vector2:
	if !camera or camera.current == false:
		camera = get_viewport().get_camera_3d()
	var vec:Vector3 = camera.global_position - global_position
	return Vector2(vec.x,vec.z)

func damage(amount:int):
	flesh.damage(amount)

func die():
	queue_free()

func should_flinch(amount:float) -> bool:
	var chance:float = data.poise - amount
	if randf_range(0,100) > chance:
		return true
	return false
	
