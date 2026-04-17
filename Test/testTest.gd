extends Node2D

var ready_to_move_to:bool = false
var tween:Tween
@onready var button: Button = $Control/Button

func _on_button_pressed() -> void:
	button.open_menu()
