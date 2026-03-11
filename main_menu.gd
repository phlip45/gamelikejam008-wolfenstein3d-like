extends Node3D

func _on_play_pressed() -> void:
	Global.scene_changer.change_scene("res://level_1.tscn")
