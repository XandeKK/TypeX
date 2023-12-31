extends Panel

@export var canvas : SubViewportContainer

@onready var body_outlines : PanelContainer = $MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/BodyOutlines
@onready var body_shakes : PanelContainer = $MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/BodyShakes

func _ready():
	canvas.object_focus_changed.connect(set_values)
	set_values(null)

func blank_all():
	body_outlines.blank_all()
	body_shakes.blank_all()

func set_values(node : Control):
	blank_all()
	if not node:
		return
	
	body_outlines.set_values(node)
	body_shakes.set_values(node)
