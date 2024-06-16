class_name LinkedList

class LinkedListItem:
	var prev : LinkedListItem = null
	var next : LinkedListItem = null
	var data : Variant = null
	
	func _init(_data : Variant):
		data = _data
	
	func _to_string() -> String:
		return str(data)

var head : LinkedListItem = null
var tail : LinkedListItem = null
var list_size : int = 0

func is_linked(node : LinkedListItem) -> bool:
	return not ((node && node.prev == null && node.next == null && tail != node && head != node) or is_empty())

func size() -> int:
	return list_size

func is_empty() -> bool:
	return list_size == 0

func first() -> LinkedListItem:
	return head

func last() -> LinkedListItem:
	return tail

func _to_string() -> String:
	return str(to_array())

func to_array() -> Array:
	var node : LinkedListItem = head
	var result : Array = []
	
	while node != null:
		result.append(node)
		node = node.next
	
	return result

func for_each(callable : Callable) -> void:
	var node : LinkedListItem = head
	while node != null:
		callable.call(node)
		node = node.next

func contains(_node : LinkedListItem) -> bool:
	var node : LinkedListItem = head
	if not is_linked(_node):
		return false
	
	while node != null:
		if node == _node:
			return true
		node = node.next
	return false

func at(_index : int) -> LinkedListItem:
	var node : LinkedListItem = head
	var index : int = 0
	
	if _index >= list_size or _index < 0:
		return null
	
	while node != null:
		if _index == index:
			return node
		node = node.next
		index += 1
	return null

func insert_after(node : LinkedListItem, new_node : LinkedListItem) -> LinkedList:
	if not is_linked(node):
		return self
	
	new_node.prev = node
	new_node.next = node.next
	
	if node.next == null:
		tail = new_node
	else:
		node.next.prev = new_node
	
	node.next = new_node
	list_size += 1
	
	return self

func insert_before(node : LinkedListItem, new_node : LinkedListItem) -> LinkedList:
	if not is_linked(node):
		return self
	
	new_node.prev = node.prev
	new_node.next = node
	
	if node.prev == null:
		head = new_node
	else:
		node.prev.next = new_node
	
	node.prev = new_node
	list_size += 1
	
	return self

func push(node : LinkedListItem) -> LinkedList:
	if head == null:
		unshift(node)
	else:
		insert_after(tail, node)
	return self

func unshift(node : LinkedListItem) -> LinkedList:
	if head == null:
		head = node
		tail = node
		node.prev = null
		node.next = null
		list_size += 1
	else:
		insert_before(head, node)
	return self

func remove(node : LinkedListItem) -> LinkedList:
	if not is_linked(node):
		return self
	
	if node.prev == null:
		head = node.next
	else:
		node.prev.next = node.next
	
	if node.next == null:
		tail = node.prev
	else:
		node.next.prev = node.prev
	
	list_size -= 1
	return self

func pop() -> LinkedListItem:
	if tail == null:
		return null

	var node : LinkedListItem = tail
	tail.prev.next = null
	tail = tail.prev
	list_size -= 1
	node.prev = null
	node.next = null
	return node

func shift() -> LinkedListItem:
	if head == null:
		return null
	
	var node : LinkedListItem = head
	head.next.prev = null
	head = head.next
	list_size -= 1
	node.prev = null
	node.next = null
	return node
