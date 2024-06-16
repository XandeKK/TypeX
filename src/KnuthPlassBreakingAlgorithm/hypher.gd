class_name Hypher

var trie : Dictionary
var left_min : int
var right_min : int
var exceptions : Dictionary

func _init(language : Dictionary):
	trie = create_trie(language['patterns'])
	left_min = language['leftmin']
	right_min = language['rightmin']
	exceptions = {}
	
	if language.has('exceptions'):
		var _exceptions : PackedStringArray = language['exceptions'].split(',')
		for exception : String in _exceptions:
			var index : int = exception.find('=')
			var hyphenation_marker : String = '=' if index != 1 else '-'
			exceptions[exception.replace(hyphenation_marker, '')] = exception.split(hyphenation_marker) 

func create_trie(pattern_object : Dictionary) -> Dictionary:
	var tree : Dictionary = {
		'_points': []
	}
	var patterns : Array
	
	for size : int in pattern_object:
		if pattern_object.has(size):
			var regex : RegEx = RegEx.new()
			regex.compile('.{1,' + str(+size)  +'}')
			patterns = regex.search_all(pattern_object[size]).map(func(pattern): return pattern.get_string())
			
			for pattern : String in patterns:
				regex.compile('[0-9]')
				
				var chars : PackedStringArray = regex.sub(pattern, '', true).split('')
				regex.compile('\\D')
				var points : Array = split_with_regex(pattern, regex)
				var t : Dictionary = tree
				
				for _char : String in chars:
					var code_point : int = _char.to_wchar_buffer()[0]
					
					if !t.has(code_point):
						t[code_point] = {}
					t = t[code_point]
				
				t._points = points.map(func(point): return point if point else 0)
	return tree

func hyphenate(word : String):
	var character_points : Array = []
	var characters : PackedStringArray
	var original_characters : PackedStringArray
	var word_length : int
	var points : Array = []
	var node : Dictionary
	var node_points : Array
	var result = ['']
	
	if exceptions.has(word):
		return exceptions[word]
	
	if word.find('\u00AD') != -1:
		return [word]
	
	word = '_' + word + '_'
	
	characters = word.to_lower().split()
	original_characters = word.split()
	word_length = characters.size()
	
	for i in range(word_length):
		points.append(0)
		character_points.append(characters[i].to_wchar_buffer()[0])
	
	for i in range(word_length):
		node = trie
		for j in range(i, word_length):
			node = node[character_points[j]] if node.has(character_points[j]) else {}
			
			if not node.is_empty():
				node_points = node._points if node.has('_points') else []
				if not node_points.is_empty():
					var node_points_length : int = node_points.size()
					for k in range(node_points_length):
						if points.size() > i + k:
							points[i + k] = max(points[i + k], int(node_points[k]))
						else:
							points.append(0)
			else:
				break
	
	for i in range(1, word_length - 1):
		if i > left_min and i < (word_length - right_min) and points[i] % 2:
			result.append(original_characters[i])
		else:
			result[result.size() - 1] += original_characters[i]
	
	return result

func split_with_regex(input : String, regex : RegEx) -> Array:
	var matches : Array = regex.search_all(input)
	var result : Array = []
	var last_pos : int = 0

	for _match in matches:
		var start : int = _match.get_start()
		var end : int = _match.get_end()

		if start > last_pos:
			result.append(input.substr(last_pos, start - last_pos))
		else:
			result.append("")

		last_pos = end

	if last_pos < input.length():
		result.append(input.substr(last_pos, input.length() - last_pos))
	else:
		result.append("")

	return result
