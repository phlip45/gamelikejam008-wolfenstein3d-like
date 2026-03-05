extends Node3D

@onready var item_list: ItemList = $CanvasLayer/Control/HFlowContainer/Card/ItemList

func _on_item_list_focus_entered() -> void:
	item_list.grab_focus()
