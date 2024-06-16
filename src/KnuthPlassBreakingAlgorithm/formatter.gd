class_name Formatter

var linebreak : Linebreak
var space_width : int
var o : Dictionary
var hyphen_width : int
var hyphen_penalty : int
var h : Hypher
var measure_text : Callable
var defaults : Dictionary = {
	'space': {
		'width': 3,
		'stretch': 6,
		'shrink': 9
	}
}

func formatter(_measure_text : Callable, options : Dictionary = {}) -> Dictionary:
	linebreak = Linebreak.new()
	
	space_width = _measure_text.call(' ')
	o = {
		'space': {
			'width': options.space.width if options else 3,
			'stretch': options.space.stretch if options else 6,
			'shrink': options.space.shrink if options else 9
		}
	}
	var hyphenation_patterns : HyphenationPatterns = HyphenationPatterns.new()
	h = Hypher.new(hyphenation_patterns.languages[Preference.general.language])
	hyphen_width = _measure_text.call('-')
	measure_text = _measure_text
	hyphen_penalty = 100
	
	return {
		'center': center,
		'justify': justify,
		'left': left
	}

func center(text : String) -> Array:
	var nodes : Array = []
	var words : PackedStringArray = text.split(' ')
	
	nodes.append(linebreak.box(0, ''))
	nodes.append(linebreak.glue(0, 12, 0))
	
	var index : int = 0
	for word : String in words:
		var hyphenated : Array = h.hyphenate(word)
		if hyphenated.size() > 1 and word.length() > 4:
			var part_index : int = 0
			for part in hyphenated:
				nodes.append(linebreak.box(measure_text.call(part), part))
				if part_index != hyphenated.size() - 1:
					nodes.append(linebreak.penalty(hyphen_width, hyphen_penalty, 1))
				part_index += 1
		else:
			nodes.append(linebreak.box(measure_text.call(word), word))
		
		if index == words.size() - 1:
			nodes.append(linebreak.glue(0, 12, 0))
			nodes.append(linebreak.penalty(0, -linebreak.infinity, 0))
		else:
			nodes.append(linebreak.glue(0, 12, 0))
			nodes.append(linebreak.penalty(0, 0, 0))
			nodes.append(linebreak.glue(space_width, -24, 0))
			nodes.append(linebreak.box(0, ''))
			nodes.append(linebreak.penalty(0, linebreak.infinity, 0))
			nodes.append(linebreak.glue(0, 12, 0))
		index += 1
	return nodes

func justify(text : String) -> Array:
	var nodes : Array = []
	var words : PackedStringArray = text.split(' ')
	var space_stretch : float = (space_width * o.space.width) / o.space.stretch
	var space_shrink : float = (space_width * o.space.width) / o.space.shrink
	
	var index : int = 0
	for word : String in words:
		var hyphenated : Array = h.hyphenate(word)
		if hyphenated.size() > 1 and word.length() > 4:
			var part_index : int = 0
			for part in hyphenated:
				nodes.append(linebreak.box(measure_text.call(part), part))
				if part_index != hyphenated.size() - 1:
					nodes.append(linebreak.penalty(hyphen_width, hyphen_penalty, 1))
				part_index += 1
		else:
			nodes.append(linebreak.box(measure_text.call(word), word))
		
		if index == words.size() - 1:
			nodes.append(linebreak.glue(0, linebreak.infinity, 0))
			nodes.append(linebreak.penalty(0, -linebreak.infinity, 1))
		else:
			nodes.append(linebreak.glue(space_width, space_stretch, space_shrink))
		index += 1
	return nodes

func left(text : String) -> Array:
	var nodes : Array = []
	var words : PackedStringArray = text.split(' ')
	
	var index : int = 0
	for word : String in words:
		var hyphenated : Array = h.hyphenate(word)
		if hyphenated.size() > 1 and word.length() > 4:
			var part_index : int = 0
			for part in hyphenated:
				nodes.append(linebreak.bool(measure_text.call(part), part))
				if part_index != hyphenated.size() - 1:
					nodes.append(linebreak.penalty(hyphen_width, hyphen_penalty, 1))
				part_index += 1
		else:
			nodes.append(linebreak.box(measure_text.call(word), word))
		
		if index == words.size() - 1:
			nodes.append(linebreak.glue(0, linebreak.infinity, 0))
			nodes.append(linebreak.penalty(0, -linebreak.infinity, 1))
		else:
			nodes.append(linebreak.glue(0, 12, 0))
			nodes.append(linebreak.penalty(0, 0, 0))
			nodes.append(linebreak.glue(space_width, -12, 0))
		index += 1
	
	return nodes
