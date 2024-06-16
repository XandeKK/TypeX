class_name Linebreak

var options : Dictionary
var active_nodes : LinkedList
var sum : Dictionary
var line_lengths : Array
var breaks : Array
var tmp : Variant
var nodes : Array
var infinity : int = 10000

func linebreak(_nodes : Array, lines : Array, settings : Dictionary) -> Array:
	options = {
		'demerits': {
			'line': settings.demerits.line if settings.has('demerits') and settings.demerits.has('line') else 10,
			'flagged': settings.demerits.flagged if settings.has('demerits') and settings.demerits.has('flagged') else 100,
			'fitness': settings.demerits.fitness if settings.has('demerits') and settings.demerits.has('fitness') else 3000,
		},
		'tolerance': settings.tolerance if settings.has('tolerance') else 2,
	}
	active_nodes = LinkedList.new()
	sum = {
		'width': 0,
		'stretch': 0,
		'shrink': 0
	}
	line_lengths = lines
	breaks = []
	tmp = {
		'data': {
			'demerits': INF
		}
	}
	nodes = _nodes
	
	active_nodes.push(LinkedList.LinkedListItem.new(break_point(0, 0, 0, 0, 0, null, null)))
	
	var index : int = 0
	for node in nodes:
		if node.type == 'box':
			sum.width += node.width
		elif node.type == 'glue':
			if index > 0 and nodes[index - 1].type == 'box':
				main_loop(node, index, nodes)
			
			sum.width += node.width
			sum.stretch += node.stretch
			sum.shrink += node.shrink
		elif node.type == 'penalty' and node.penalty != infinity:
			main_loop(node, index, nodes)
		index += 1
	
	if active_nodes.size() != 0:
		active_nodes.for_each(func(node):
			if node.data.demerits < tmp.data.demerits:
				tmp = node
		)
		
		while tmp != null:
			breaks.append({
				'position': tmp.data.position,
				'ratio': tmp.data.ratio
			})
			tmp = tmp.data.previous
		breaks.reverse()
		return breaks
	return []

func break_point(position : int, demerits : float, ratio : float, line : int, fitness_class : int, totals : Variant, previous : Variant):
	return {
		'position': position,
		'demerits': demerits,
		'ratio': ratio,
		'line': line,
		'fitness_class': fitness_class,
		'totals': totals if totals else {
			'width': 0,
			'stretch': 0,
			'shrink': 0
		},
		'previous': previous
	}

func compute_cost(_start : int, end : int, active : Dictionary, current_line : int) -> float:
	var width : float = sum.width - active.totals.width
	var stretch : float = 0
	var shrink : float = 0
	var line_length : float = line_lengths[current_line - 1] if current_line < line_lengths.size() else line_lengths[line_lengths.size() - 1]
	
	if nodes[end].type == 'penalty':
		width += nodes[end].width
	
	if width < line_length:
		stretch = sum.stretch - active.totals.stretch
		
		if stretch > 0:
			return (line_length - width) / stretch
		else:
			return infinity
	elif width > line_length:
		shrink = sum.shrink - active.totals.shrink
		
		if shrink > 0:
			return (line_length - width) / shrink
		else:
			return infinity
	else:
		return 0

func compute_sum(break_point_index) -> Dictionary:
	var result : Dictionary = {
		'width': sum.width,
		'stretch': sum.stretch,
		'shrink': sum.shrink
	}
	
	for i in range(break_point_index, nodes.size()):
		if nodes[i].type == 'glue':
			result.width += nodes[i].width
			result.stretch += nodes[i].stretch
			result.shrink += nodes[i].shrink
		elif nodes[i].type == 'box' or nodes[i].type == 'penalty' and nodes[i].penalty == -infinity and i > break_point_index:
			break
	return result

func main_loop(node, index, _nodes):
	var active : LinkedList.LinkedListItem = active_nodes.first()
	var next : Variant = null
	var ratio : float = 0
	var demerits : float = 0
	var candidates : Array = []
	var badness : float
	var current_line : int = 0
	var tmp_sum : Dictionary
	var current_class : int = 0
	var candidate : Dictionary
	var new_node : LinkedList.LinkedListItem
	
	while active != null:
		candidates = [
			{
				'demerits': INF
			},
			{
				'demerits': INF
			},
			{
				'demerits': INF
			},
			{
				'demerits': INF
			}
		]
		
		while active != null:
			next = active.next
			current_line = active.data.line + 1
			ratio = compute_cost(active.data.position, index, active.data, current_line)
			
			if ratio < -1 or node.type == 'penalty' and node.penalty == -infinity:
				active_nodes.remove(active)
			
			if -1 <= ratio and ratio <= options.tolerance:
				badness = 100 * pow(abs(ratio), 3)
				
				if node.type == 'penalty' and node.penalty >= 0:
					demerits = pow(options.demerits.line + badness, 2) + pow(node.penalty, 2)
				elif node.type == 'penalty' and node.penalty != -infinity:
					demerits = pow(options.demerits.line + badness, 2) - pow(node.penalty, 2)
				else:
					demerits = pow(options.demerits.line + badness, 2);
				
				if node.type == 'penalty' and nodes[active.data.position].type == 'penalty':
					demerits += options.demerits.flagged * node.flagged * _nodes[active.data.position].flagged
				
				if ratio < -0.5:
					current_class = 0
				elif ratio <= 0.5:
					current_class = 1
				elif (ratio <= 1):
					current_class = 2
				else:
					current_class = 3
				
				if abs(current_class - active.data.fitness_class) > 1:
					demerits += options.demerits.fitness
				
				demerits += active.data.demerits
				
				if demerits < candidates[current_class].demerits:
					candidates[current_class] = {
						'active': active,
						'demerits': demerits,
						'ratio': ratio
					}
			
			active = next
			
			if active != null and active.data.line >= current_line:
				break
		
		tmp_sum = compute_sum(index)
		
		for fitness_class in range(0, candidates.size()):
			candidate = candidates[fitness_class]
			
			if candidate.demerits < INF:
				new_node = LinkedList.LinkedListItem.new(break_point(index, candidate.demerits, candidate.ratio,
					candidate.active.data.line + 1, fitness_class, tmp_sum, candidate.active))
				
				if active != null:
					active_nodes.insert_before(active, new_node)
				else:
					active_nodes.push(new_node)


func glue(width, stretch, shrink) -> Dictionary:
	return {
		'type': 'glue',
		'width': width,
		'stretch': stretch,
		'shrink': shrink
	}

func box(width, value)  -> Dictionary:
	return {
		'type': 'box',
		'width': width,
		'value': value
	}

func penalty(width, _penalty, flagged) -> Dictionary:
	return {
		'type': 'penalty',
		'width': width,
		'penalty': _penalty,
		'flagged': flagged,
	}
