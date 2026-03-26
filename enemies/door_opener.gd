extends Area3D


var doors_to_open:Array[Door] = []

func _ready() -> void:
	open_doors()

func open_doors():
	for door in doors_to_open:
		door.open()
	var tween:Tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(open_doors)

func _on_area_entered(area: Area3D) -> void:
	if area and area.is_in_group("door"):
		doors_to_open.append(area as Door)

func _on_area_exited(area: Area3D) -> void:
	if area and area.is_in_group("door"):
		doors_to_open.erase(area as Door)
