extends CharacterBody3D
class_name Actor

func has_flesh() -> bool:
	if self.flesh:
		return true
	return false

func damage(_damage:Damage):
	push_warning("Damaged Fleshless Freakazoid")
