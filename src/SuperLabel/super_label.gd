extends Control

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var text : Control = $SubViewportContainer/SubViewport/Text
@onready var sub_viewport_container : SubViewportContainer = $SubViewportContainer

var move : Move = Move.new()
var rotation_node : Rotation = Rotation.new()

var focus : bool = false : get = _get_focus
var can_draw : bool = true : set = _set_can_draw

signal focused(node : Control)
signal focus_changed
signal rotation_changed(value)

func _ready():
	move.target = self
	rotation_node.target = self
	
	add_child(rotation_node)
	
	resized.connect(readjust_size)

	readjust_size()

func _input(event):
	move.input(event)

func _draw():
	if not can_draw:
		return

	if focus:
		var left = text.style_box.get_margin(SIDE_LEFT)
		var right = text.style_box.get_margin(SIDE_RIGHT)
		var top = text.style_box.get_margin(SIDE_TOP)
		var bottom = text.style_box.get_margin(SIDE_BOTTOM)
		# draw content margin rect
		draw_rect(Rect2(Vector2(left, top), size - Vector2(right + left, bottom + top)), Preference.colors.padding.active, false, 3)
		# draw rotation rect
		draw_rect(Rect2(rotation_node.position, rotation_node.size), Preference.colors.text_edge.active)
		# draw text rect
		draw_rect(Rect2(Vector2.ZERO, size), Preference.colors.text_edge.active, false, 3)
	else:
		# draw text rect
		draw_rect(Rect2(Vector2.ZERO, size), Preference.colors.text_edge.deactive, false, 3)

func init(_position : Vector2, _size : Vector2, style : Preference.HQStyles) -> void:
	self.position = _position
	size = _size
	
	var font_name = Preference.hq_styles[style]['default_font']
	
	if font_name and FontConfigManager.fonts.has(font_name):
		text.font_name = font_name
		text.font_settings = FontConfigManager.fonts[font_name]
	
	text.font_size = Preference.hq_styles[style]['font_size']

func readjust_size():
	sub_viewport_container.size = size
	#sub_viewport.size = size
	text.size = size
	
	pivot_offset = size / 2
	rotation_node.readjust_size()
	
	text._shape()

func _get_focus() -> bool:
	return focus

func set_focus(value : bool = true, emit : bool = true) -> void:
	focus = value
	queue_redraw()
	emit_signal('focused', self) if emit else null
	emit_signal('focus_changed')

func _set_can_draw(value : bool) -> void:
	can_draw = value

func convert_to_degrees(value : float):
	value = int(rad_to_deg(value))
	if value < 0:
		value = 360 + value
	return value

func set_rotation_text(value : float):
	value = convert_to_degrees(value)
	rotation_degrees = value
	emit_signal('rotation_changed', value)

func set_content_margin(margin : Side, offset : float):
	text.set_content_margin(margin, offset)
	queue_redraw()

func to_dictionary() -> Dictionary:
	return {
		'position': position,
		'size': size,
		'rotation_degrees': rotation_degrees,
		'text': text.to_dictionary()
	}

func load(data : Dictionary) -> void:
	rotation_degrees = data['rotation_degrees']
	
	text.load(data['text'])

func _exit_tree():
	move.free()
