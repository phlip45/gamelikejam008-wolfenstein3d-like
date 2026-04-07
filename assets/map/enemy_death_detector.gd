extends Activateable
class_name EnemyDeathDetector

@export var active:bool = false
@export var enemies:Array[Enemy]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy in enemies:
		enemy.died.connect(on_enemy_death.bind(enemy), CONNECT_ONE_SHOT)

func on_enemy_death(enemy):
	enemies.erase(enemy)
	if enemies.size() == 0:
		active = !active
		active_changed.emit()
	
