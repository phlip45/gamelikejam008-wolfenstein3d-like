extends Node

@export_file("*.json") var json_paths:Array[String]
var json_path:String
var texture_path:String
var save_path_name:String

func _ready() -> void:
	_assemble()

func _assemble() -> void:
	for i in json_paths.size():
		json_path = json_paths[i]
		texture_path = json_path.substr(0,json_path.length() - 4) + "png"
		var filename:String = json_path.get_file()  # "horse_back_right.json"
		var name_only:String = filename.get_basename()  # "horse_back_right"
		save_path_name = name_only
		_run()
	#get_tree().quit()

func _run() -> void:
	print("working")
	var save_path:String = "res://tools/sprite_importer_output/%s.tres" % save_path_name

	var file:FileAccess = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Cant open JSON")
		return

	var json_text:String = file.get_as_text()
	file.close()

	var json:JSON = JSON.new()
	if json.parse(json_text) != OK:
		push_error("Bad JSON")
		return

	var data:Dictionary = json.data
	var frames:Dictionary = data["frames"]
	var texture:Texture2D = load(texture_path)
	if texture == null:
		push_error("Cant load texture")
		return

	var anims:Dictionary = {} 

	for frame_key:String in frames.keys():
		var parts:Array = frame_key.split("#")
		if parts.size() < 2:
			continue
		var anim_part:String = parts[1].strip_edges()
		var anim_name:String = anim_part.split(" ")[0]
		if not anims.has(anim_name):
			anims[anim_name] = []
		anims[anim_name].append(frame_key)

	var sprite_frames:SpriteFrames = SpriteFrames.new()
	
	for anim_name:String in anims.keys():
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 60.0) # prolly shouldn't be hardcoded
		for frame_key:String in anims[anim_name]:
			var frame_info:Dictionary = frames[frame_key]
			var f_rect:Dictionary = frame_info["frame"]

			var atlas:AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				f_rect["x"], f_rect["y"], f_rect["w"], f_rect["h"]
			)

			var duration:float = float(frame_info["duration"]) / 1000.0  * 60.0
			sprite_frames.add_frame(anim_name, atlas, duration)

		sprite_frames.set_animation_loop(anim_name, true)

	ResourceSaver.save(sprite_frames, save_path)
