class_name TextLayoutManager

var linebreak : Linebreak
var formatter : Formatter
var text : Text
var tolerance : int = 10

func _init(_text : Text):
	linebreak = Linebreak.new()
	formatter = Formatter.new()
	text = _text

func justify_text():
	var format : Dictionary = formatter.formatter(measure_text)
	var nodes : Array = format['justify'].call(text.text);
	
	var line_lengths : Array = calculate_line_lengths(text.text, text.size.x * 0.8)
	
	var breaks = linebreak.linebreak(nodes, line_lengths, {'tolerance': tolerance})
	
	var lines : Array = []
	var point : int
	var ratio : float
	var line_start : int = 0
	
	for i in range(1, breaks.size()):
		point = breaks[i].position
		ratio = breaks[i].ratio
		
		for j in range(line_start, nodes.size()):
			if nodes[j].type == 'box' or (nodes[j].type == 'penalty' and nodes[j].penalty == -linebreak.infinity):
				line_start = j
				break
		
		lines.append({'ratio': ratio, 'nodes': nodes.slice(line_start, point + 1), 'position': point})
		line_start = point
	
	var _text : String = ''
	if lines.is_empty():
		Notification.message("Não foi possível justify")
		return
	else:
		for line in lines:
			var index = 0
			for node in line.nodes:
				if node.type == 'box':
					_text += node.value
				elif node.type == 'glue':
					_text += ' '
				elif node.type == 'penalty' and node.penalty == 100 and index == line.nodes.size() - 1:
					_text += '-'
				
				index += 1
			_text += '\n'
	
	text.text = _text

func measure_text(_str : String) -> float:
	var current_font : FontVariation
	
	if text.bold and text.italic:
		current_font = text.font_settings['bold-italic']
	elif text.bold:
		current_font = text.font_settings['bold']
	elif text.italic:
		current_font = text.font_settings['italic']
	else:
		current_font = text.font_settings['regular']
	
	return current_font.get_string_size(_str, HORIZONTAL_ALIGNMENT_CENTER, -1, text.font_size).x

func calculate_line_lengths(_text: String, text_size_x: float) -> Array:
	var wrapped_lines = wrap_text(_text, text_size_x)
	var num_lines = wrapped_lines.size()

	var line_lengths: Array = []
	var radius: float = text_size_x / 2
	
	for j in range(0, radius * 2, 21):
		line_lengths.append(round(sqrt((radius - j / 2.0) * (8 * j))))

	line_lengths = line_lengths.filter(func(v):
		return v > 30;
	)
	
	var middle_line_lengths : int = ceil(line_lengths.size() / 2.0)
	var middle_wrapeed_lines : int = ceil(num_lines / 2.0)
	
	line_lengths = line_lengths.slice(middle_line_lengths - middle_wrapeed_lines - 1, middle_line_lengths + middle_wrapeed_lines)
	
	return line_lengths

func wrap_text(_text: String, max_width: float) -> Array:
	var lines: Array = []
	var current_line: String = ""
	var words: Array = _text.split(" ")
	
	for word in words:
		if current_line.is_empty():
			current_line = word
		else:
			var test_line: String = current_line + " " + word
			if measure_text(test_line) <= max_width:
				current_line = test_line
			else:
				lines.append(current_line)
				current_line = word
	
	if not current_line.is_empty():
		lines.append(current_line)
	
	return lines
