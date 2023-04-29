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
	add_child(item)
	items.push_back(item)
	arrange()

func pop() -> Node:
	var item = items.pop_back()
	remove_child(item)
	arrange()
	return item

func arrange():
	for i in items.size():
		items[i].position.y = (i + 1) * .05
