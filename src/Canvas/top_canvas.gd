extends SubViewportContainer

@onready var camera : Camera2D = $SubViewport/Camera2D
@onready var bottom_canvas : SubViewportContainer = $SubViewport/BottomCanvas
@onready var bottom_canvas_sub_viewport : SubViewport = $SubViewport/BottomCanvas/SubViewport
@onready var raw_image : TextureRect = $SubViewport/BottomCanvas/SubViewport/RawImage
@onready var cleaned_image : TextureRect = $SubViewport/BottomCanvas/SubViewport/CleanedImage
@onready var draw_observer : Control = $SubViewport/BottomCanvas/SubViewport/DrawObserver
@onready var objects : Node = $SubViewport/BottomCanvas/SubViewport/Objects

var focused_object : Control = null : get = get_object

signal object_focus_changed(node : Control)
signal object_added(node : Control)
signal object_removed(node : Control)

func _ready() -> void:
	draw_observer.target = self

func load_raw_image(texture : ImageTexture) -> void:
	raw_image.texture = texture
	raw_image.size = texture.get_size()

func load_cleaned_image(texture : ImageTexture) -> void:
	cleaned_image.texture = texture
	bottom_canvas.size = texture.get_size()
	cleaned_image.size = texture.get_size()
	
	camera.position = Vector2(texture.get_size().x / 2, get_viewport().size.y - 50)

func add_object(packed_scene : PackedScene, start_position : Vector2, end_position : Vector2, porperties : Dictionary = {}) -> void:
	if not packed_scene:
		return

	var obj = packed_scene.instantiate()
	objects.add_child(obj)
	obj.focused.connect(focus)
	var min_pos = Vector2(min(start_position.x, end_position.x), min(start_position.y, end_position.y))
	var max_pos = Vector2(max(start_position.x, end_position.x), max(start_position.y, end_position.y))
	obj.init(min_pos, max_pos - min_pos)
	
	emit_signal('object_added', obj)

func remove_object(node : Control):
	focus(null)
	node.queue_free()
	emit_signal('object_removed', node)

func focus(node : Control) -> void:
	if focused_object:
		focused_object.set_focus(false, false)
	if focused_object == node:
		return
	focused_object = node
	emit_signal('object_focus_changed', node)

func get_object() -> Control:
	return focused_object
