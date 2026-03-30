extends CanvasLayer
class_name UI

@export var gun_sprite: AnimatedSprite2D
@export var damage_mask: TextureRect
@export var face: AnimatedSprite2D

@export var health: RichTextLabel
@export var ammo: RichTextLabel
@export var time: RichTextLabel
@export var signal_strength: AnimatedSprite2D

@onready var exit_opened_text: RichTextLabel = $Hud/VBoxContainer/GameView/ExitOpenedText
@export var died_splash: ColorRect

var tween:Tween
var player:Player

func _init() -> void:
	Global.ui = self
	
func _ready() -> void:
	face.play("Idle")
	player = Global.player
	player.flesh.health_changed.connect(on_health_change)
	player.inventory.credit_changed.connect(on_credit_change)
	Global.level.kessleroid_killed.connect(on_kessleroid_killed)
	on_kessleroid_killed(Global.level.kessleroids_to_unlock_exit.x)

func _process(_delta: float) -> void:
	time.text = format_time(Global.level.timer)

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

func on_health_change(new_health:int):
	health.text = str(new_health)

func on_credit_change(new_credit_amount:int):
	ammo.text = str(new_credit_amount)

func on_kessleroid_killed(remaining:int):
	var amount_left:int = max(7 - remaining, 0)
	signal_strength.animation = str(amount_left) + ".ase"
	if remaining == 0:
		var _tween:Tween = create_tween()
		_tween.tween_property(exit_opened_text,"modulate",Color.WHITE,1)
		_tween.tween_interval(3)
		_tween.tween_property(exit_opened_text,"modulate",Color.TRANSPARENT,1)

func display_death():
	if gun_sprite.sprite_frames.has_animation("Holster"):
		play_gun_anim("Holster")
	var _tween:Tween = create_tween()
	_tween.tween_property(died_splash, "modulate", Color.WHITE,0.6)

func format_time(elapsed:float) -> String:
	var total_seconds:int = int(elapsed)
	
	@warning_ignore("integer_division")
	var minutes:int = total_seconds / 60
	var seconds:int = total_seconds % 60
	
	if minutes >= 9:
		minutes = 9
		seconds = total_seconds - (9 * 60)
		
		if seconds > 99:
			seconds = 99
	
	var seconds_str:String = str(seconds)
	if seconds < 10:
		seconds_str = "0" + seconds_str
	
	return str(minutes) + ":" + seconds_str
