extends VBoxContainer

@onready var justify_button : Button = $JustifyButton
@onready var tolerance_input : _Input = $ToleranceInput

var text_layout_manager : TextLayoutManager : set = set_text_layout_manager

func blank_all() -> void:
	text_layout_manager = null
	
	justify_button.disabled = true
	tolerance_input.set_editable(false)

func set_values(value : TextLayoutManager) -> void:
	blank_all()
	
	text_layout_manager = value
	
	justify_button.disabled = false
	tolerance_input.set_editable(true)

func set_text_layout_manager(value : TextLayoutManager) -> void:
	text_layout_manager = value
	
	if text_layout_manager:
		tolerance_input.set_value(10)

func _on_justify_button_pressed() -> void:
	text_layout_manager.justify_text()

func _on_tolerance_input_changed(value : int) -> void:
	text_layout_manager.tolerance = value
