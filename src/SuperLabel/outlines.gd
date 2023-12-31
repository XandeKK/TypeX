extends Control

var outline : PackedScene = load("res://src/SuperLabel/outline.tscn")
var parent : Control : set = set_parent

func get_outlines() -> Array:
	return get_children().filter(func(child): return child.is_global)

func add() -> void:
	var _outline = outline.instantiate()
	_outline.parent = parent
	_outline.is_global = true
	add_child(_outline)

func remove(node : Control) -> void:
	remove_child(node)
	node.queue_free()

func set_parent(value : Control):
	parent = value

func to_dictionary() -> Dictionary:
	return {
		'list': get_outlines().map(func(outline): return outline.to_dictionary())
	}

func load(data : Dictionary) -> void:
	for _outline in data['list']:
		add()
		get_outlines()[-1].load(_outline)
