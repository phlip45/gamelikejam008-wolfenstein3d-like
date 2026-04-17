extends Button

const CARD_MENU = preload("uid://bj25ccksukk8h")

@onready var marker_2d: Marker2D = $Marker2D

func open_menu():
	var new_card_menu:Button = CARD_MENU.instantiate()
	new_card_menu.visible = true
	new_card_menu.top_level = true
	get_tree().current_scene.add_child(new_card_menu)
	new_card_menu.global_position = marker_2d.global_position
