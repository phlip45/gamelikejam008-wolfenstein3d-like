@abstract
extends Resource

class_name Brain
var enemy:Enemy

@abstract func setup(_enemy:Enemy)
@abstract func process(_delta:float)
@export var projectile_cloaca_position:Vector3

func can_see_player() -> bool:
	enemy.ray_cast_3d.look_at(Global.player.head.global_position + Vector3(0,-.2,0))
	enemy.ray_cast_3d.force_raycast_update()
	var collider = enemy.ray_cast_3d.get_collider()
	if collider is not Player: return false
	return true

func is_colinear_with_up(a: Vector3, b: Vector3) -> bool:
	var v = (b - a).normalized()
	# If the absolute dot product is ~1, then v is parallel (colinear) with Vector3.UP
	return abs(v.dot(Vector3.UP)) > 0.9999

func shortest_rotation_path(from_rotation: Vector3, to_rotation: Vector3) -> Vector3:
	var normalize_angle_diff:Callable = func(angle_diff: float) -> float:
		angle_diff = fmod(angle_diff + PI, TAU)
		if angle_diff < 0:
			angle_diff += TAU
		return angle_diff - PI

	var delta:Vector3 = to_rotation - from_rotation
	delta.x = normalize_angle_diff.call(delta.x)
	delta.y = normalize_angle_diff.call(delta.y)
	delta.z = normalize_angle_diff.call(delta.z)
	return from_rotation + delta



func rotate_toward_target()-> void:
	var next_location = enemy.nav_agent.get_next_path_position()
	if !is_colinear_with_up(enemy.global_position,next_location) and !enemy.global_position.is_equal_approx(next_location):
		var prev_rot:Vector3 = enemy.rotation
		enemy.look_at(next_location)
		var target_rotation:Vector3 = shortest_rotation_path(prev_rot,enemy.rotation)
		enemy.rotation = prev_rot.move_toward(target_rotation,.1)
			
	enemy.rotation.x = 0
	enemy.rotation.z = 0
