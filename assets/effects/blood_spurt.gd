extends Node3D
class_name BloodSpurt

@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var cpu_particles_3d_3: CPUParticles3D = $CPUParticles3D3
static var scene:String = "res://assets/effects/blood_spurt.tscn"

static func spawn(pos:Vector3) -> void:
	var packed_scene:PackedScene = await Global.load_scene(scene)
	var spurt:BloodSpurt = packed_scene.instantiate()
	spurt.position = pos
	Global.level.add_child.call_deferred(spurt)

func _ready() -> void:
	cpu_particles_3d.emitting = true
	cpu_particles_3d_3.emitting = true
	cpu_particles_3d.finished.connect(queue_free)
