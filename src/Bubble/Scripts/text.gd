extends TextBase
class_name Text

@onready var text_renderer : Control = $TextRenderer
@onready var outline_manager : OutlineManager = $OutlineManager
@onready var motion_blur : MotionBlur
@onready var blur : Blur
@onready var gradient : GradientText

var text_path : TextPath2D
var text_layout_manager : TextLayoutManager

func _ready():
	text_renderer.text = self
	outline_manager.text = self
	text_styles.text = self
	text_layout_manager = TextLayoutManager.new(self)

func active_motion_blur(value : bool) -> void:
	if value:
		motion_blur = Global.motion_blur.instantiate()
		add_child(motion_blur)
		
		motion_blur.anchors_preset = PRESET_FULL_RECT
	else:
		remove_child(motion_blur)
		motion_blur.queue_free()
		motion_blur = null

func active_blur(value : bool) -> void:
	if value:
		blur = Global.blur.instantiate()
		add_child(blur)
		
		blur.anchors_preset = PRESET_FULL_RECT
	else:
		remove_child(blur)
		blur.queue_free()
		blur = null

func active_gradient(value : bool) -> void:
	if value:
		gradient = Global.gradient.instantiate()
		text_renderer.add_child(gradient)
		
		gradient.anchors_preset = PRESET_FULL_RECT
	else:
		text_renderer.remove_child(gradient)
		gradient.queue_free()
		gradient = null

func to_dictionary() -> Dictionary:
	var data = {
		'text': text,
		'color': color,
		'letter_spacing': letter_spacing,
		'line_spacing': line_spacing,
		'font_size': font_size,
		'bold': bold,
		'italic': italic,
		'horizontal_alignment': horizontal_alignment,
		'uppercase': uppercase,
		'font_name': font_name,
		'text_styles': text_styles.to_dictionary(),
		'content_margins': {
			SIDE_LEFT: style_box.get_margin(SIDE_LEFT),
			SIDE_TOP: style_box.get_margin(SIDE_TOP),
			SIDE_BOTTOM: style_box.get_margin(SIDE_BOTTOM),
			SIDE_RIGHT: style_box.get_margin(SIDE_RIGHT)
		},
		'outline_manager' : outline_manager.to_dictionary()
	}
	
	for element in ['blur', 'motion_blur', 'gradient']:
		if self[element] != null:
			data[element] = self[element].to_dictionary()
		else:
			data[element] = null
	
	return data

func load(data : Dictionary) -> void:
	text = data['text']
	color = data['color']
	letter_spacing = data['letter_spacing']
	line_spacing = data['line_spacing']
	font_size = data['font_size']
	bold = data['bold']
	italic = data['italic']
	horizontal_alignment = data['horizontal_alignment']
	uppercase = data['uppercase']
	font_name = data['font_name']
	if FontConfigManager.fonts.has(font_name):
		font_settings = FontConfigManager.fonts[font_name]

	text_styles.load(data['text_styles'])
	
	set_content_margin(SIDE_LEFT, data['content_margins'][SIDE_LEFT])
	set_content_margin(SIDE_TOP, data['content_margins'][SIDE_TOP])
	set_content_margin(SIDE_BOTTOM, data['content_margins'][SIDE_BOTTOM])
	set_content_margin(SIDE_RIGHT, data['content_margins'][SIDE_RIGHT])
	
	outline_manager.load(data['outline_manager'])
	
	if data['blur']:
		active_blur(true)
		blur.load(data['blur'])
	
	if data['motion_blur']:
		active_motion_blur(true)
		motion_blur.load(data['motion_blur'])
	
	if data['gradient']:
		active_gradient(true)
		gradient.load(data['gradient'])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		TSManager.TS.free_rid(text_rid)
		for i in range(lines_rid.size()):
			TSManager.TS.free_rid(lines_rid[i])

func _exit_tree():
	if Global.canvas.bubbles.get_child(0).is_queued_for_deletion():
		TSManager.TS.free_rid(text_rid)
		for i in range(lines_rid.size()):
			TSManager.TS.free_rid(lines_rid[i])
