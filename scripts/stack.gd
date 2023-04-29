extends Node3D

class_name Stack

var items: Array[Node]

func _ready():
	for item in get_children():
		if item.name != "Base":
			items.push_back(item)
	arrange()

func activate():
	$Base.visible = true

func deactivate():
	$Base.visible = false

func push(item: Node):
	items.push_back(item)
	arrange()

func pop() -> Node:
	var item = items.pop_back()
	arrange()
	return item

func arrange():
	var current_height = .05
	for i in items.size():
		items[i].position.x = 0
		items[i].position.y = current_height
		current_height = current_height + _get_height(items[i]) + .02

func _get_height(obj):
	for child in obj.get_children():
		if child.has_method("get_aabb"):
			return child.get_aabb().size.y
	return 0.1
