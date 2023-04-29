extends Node3D

class_name Stack

var items: Array[Node]
var queued_active = false

func _ready():
	for item in get_children():
		if item.name == "nonitems":
			continue
		items.push_back(item)
	arrange()

func activate():
	queued_active = true

func deactivate():
	queued_active = false

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
	check_for_sandwich()

func _get_height(obj):
	for child in obj.get_children():
		if child.has_method("get_aabb"):
			return child.get_aabb().size.y
	return 0.1

func check_for_sandwich():
	print(items)
	if items.size() > 2 and items[0].name.begins_with("Bread") and items[-1].name.begins_with("Bread"):
		celebrate()

func celebrate():
	$nonitems/Animation.play("celebrate")

func _process(_delta):
	if queued_active != null:
		if $nonitems/Animation.current_animation == "celebrate":
			pass # wait
		else:
			if queued_active:
				$nonitems/Animation.play("activate")
			else:
				$nonitems/Animation.play("RESET")
			queued_active = null
