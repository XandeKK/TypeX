extends Node
class_name TextStyle

var parent : Control : set = set_parent
var start : int  : get = get_start, set = set_start
var end : int : get = get_end, set = set_end
var bold : bool : get = get_bold, set = set_bold
var italic : bool : get = get_italic, set = set_italic
var font_size : int : get = get_font_size, set = set_font_size
var font_settings : Dictionary : get = get_font_settings, set = set_font_settings
var color : Color : get = get_color, set = set_color
var uppercase : bool : get = get_uppercase, set = set_uppercase
var outlines : Array : get = get_outlines, set = set_outlines
var shakes : Array : get = get_shakes, set = set_shakes

#var outline_scene : PackedScene = load()
#var shake_scene : PackedScene = load()

func add_outline() -> void:
#	var outline = outline_scene.instantiate()
#	outline.start = start
#	outline.end = end
#	outline.z_index = 1
#	parent.outlines.add_child()
	pass

func remove_outline(index : int) -> void:
	if index < 0 or index >= outlines.size():
		push_error('Unable to remove. Index is out of range')
		return
	
	var outline : Control = outlines[index]
	
	parent.outlines.remove_child(outline)
	outlines.remove_at(index)
	
	outline.queue_free()

func add_shake() -> void:
#	var shake = shake_scene.instantiate()
#	shake.start = start
#	shake.end = end
#	shake.z_index = 1
#	parent.shakes.add_child()
	pass

func remove_shake(index : int) -> void:
	if index < 0 or index >= shakes.size():
		push_error('Unable to remove. Index is out of range')
		return
	
	var shake : Control = shakes[index]
	
	parent.shakes.remove_child(shake)
	shakes.remove_at(index)
	
	shake.queue_free()

func set_parent(value : Control) -> void:
	parent = value

func get_start() -> int:
	return start

func set_start(value) -> void:
	start = value
	for outline in outlines:
		outline.start = start

func get_end() -> int:
	return end

func set_end(value) -> void:
	end = value
	for outline in outlines:
		outline.end = end

func get_bold() -> bool:
	return bold

func set_bold(value) -> void:
	bold = value

func get_italic() -> bool:
	return italic

func set_italic(value) -> void:
	italic = value

func get_font_size() -> int:
	return font_size

func set_font_size(value) -> void:
	font_size = value

func get_font_settings() -> Dictionary:
	return font_settings

func set_font_settings(value) -> void:
	font_settings = value

func get_color() -> Color:
	return color

func set_color(value) -> void:
	color = value

func get_uppercase() -> bool:
	return uppercase

func set_uppercase(value) -> void:
	uppercase = value

func get_outlines() -> Array:
	return outlines

func set_outlines(value) -> void:
	outlines = value

func get_shakes() -> Array:
	return shakes

func set_shakes(value) -> void:
	shakes = value
