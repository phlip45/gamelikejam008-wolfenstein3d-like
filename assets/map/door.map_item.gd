extends Interactable
class_name Door

func open():
	if toggled: return
	toggled = true
	animation_player.play("interact")
	
func close():
	if !toggled: return
	toggled = false
	animation_player.play_backwards("interact")
