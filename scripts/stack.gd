extends Node3D

class_name Stack

var items: Array[Node]

func _ready():
	for item in get_children():
		if item.name != "Base":
			items.push_back(item)
	arrange()

func activate():
	$Base.material_override.emission_enabled = true

func deactivate():
	$Base.material_override.emission_enabled = false

func push(item: Node):
	items.push_back(item)
	arrange()

func pop() -> Node:
	var item = items.pop_back()
	return item

func arrange():
	var current_height = .05
	var tween = get_tree().create_tween()
	for i in items.size():
		var new_position = items[i].position
		new_position.x = 0
		new_position.y = current_height
		var position_diff = items[i].position - new_position
		if position_diff.length() > .02:
			tween.tween_property(items[i], "position", new_position, 0.1)
		current_height = current_height + _get_height(items[i]) + .02

func _get_height(obj):
	for child in obj.get_children():
		if child.has_method("get_aabb"):
			return child.get_aabb().size.y
	return 0.1
