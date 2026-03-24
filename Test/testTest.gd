extends SpriteBase3D

@onready var item_list: ItemList = $CanvasLayer/Control/HFlowContainer/Card/ItemList

func _on_item_list_focus_entered() -> void:
	item_list.grab_focus()

	var sprite:Sprite3D
	sprite.generate_triangle_mesh()
