extends VBoxContainer

var node : Control : set = _set_node
var parent : Control : set = _set_parent
@onready var x_input : LineEdit = $XContainer/XInput
@onready var y_input : LineEdit = $YContainer/YInput
@onready var size_input : LineEdit = $SizeContainer/SizeInput
@onready var color_picker : ColorPickerButton = $ColorContainer/ColorPickerButton

func _set_node(value : Control) -> void:
	node = value
	x_input.text = str(node.offset.x)
	y_input.text = str(node.offset.y)
	size_input.text = str(node.outline_size)
	color_picker.color = node.color

func _set_parent(value : Control) -> void:
	parent = value

func _on_x_input_changed(value):
	node.offset.x = value

func _on_y_input_changed(value):
	node.offset.y = value

func _on_size_input_changed(value):
	node.outline_size = value

func _on_color_picker_button_color_changed(color):
	node.color = color

func _on_remove_button_pressed():
	parent.remove_outline(node)
	queue_free()
