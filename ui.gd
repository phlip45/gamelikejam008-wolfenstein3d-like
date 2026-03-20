extends CanvasLayer
class_name UI

@export var gun_sprite: AnimatedSprite2D
@export var damage_mask: TextureRect
var tween:Tween

func _init() -> void:
	Global.ui = self

func play_gun_anim(anim_name:String,backwards:bool = false ,frame:int = 0) -> AnimatedSprite2D:
	if !gun_sprite.sprite_frames.has_animation(anim_name):
		push_error("Tried to '%s' with gun data '%s' but it didn't exist" % [anim_name, gun_sprite.name])
	if backwards:
		gun_sprite.play_backwards(anim_name)
	else:
		gun_sprite.play(anim_name)
	gun_sprite.frame = frame
	return gun_sprite

func change_gun(data:GunData):
	if gun_sprite.sprite_frames.has_animation("Holster"):
		play_gun_anim("Holster")
		await gun_sprite.animation_finished
	gun_sprite.sprite_frames = data.ui_sprite_frames
	gun_sprite.scale = data.ui_scale * Vector2.ONE
	gun_sprite.position = data.ui_transform_position
	gun_sprite.frame = 0
	if !gun_sprite.sprite_frames.has_animation("Wield"):
		push_error("Tried to change to gun '%s' but it didn't have a Wield animation " % data.name)
	play_gun_anim("Wield")
	await gun_sprite.animation_finished
	return
	
func flash_damage():
	damage_mask.modulate = Color.WHITE
	tween = create_tween()
	tween.tween_property(damage_mask,"modulate",Color.TRANSPARENT,.5)
