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

func spawn(item: Node):
	add_child(item)
	items.push_back(item)
	item.position.y = 2
	arrange()

func push(item: Node):
	items.push_back(item)
	arrange()

func pop() -> Node:
	var item = items.pop_back()
	return item

func arrange():
	var current_height = $nonitems/Base.position.y + $nonitems/Base.get_aabb().size.y / 2
	var tween = get_tree().create_tween()
	for i in items.size():
		var item_height = get_height(items[i])
		var new_position = items[i].position
		new_position.x = 0
		new_position.y = current_height + item_height / 2
		var position_diff = items[i].position - new_position
		if position_diff.length() > .02:
			tween.tween_property(items[i], "position", new_position, 0.1)
		current_height = current_height + item_height

func get_height(obj) -> float:
	var maybe_height = _maybe_get_height(obj)
	if maybe_height > 0:
		return maybe_height
	push_warning("no child has get_aabb for obj with name " + obj.name)
	return 0.

func _maybe_get_height(obj):
	if obj.has_method("get_aabb"):
		return (obj.get_aabb().size * obj.transform.basis.get_scale()).y
	for child in obj.get_children():
		var maybe_height = _maybe_get_height(child)
		if maybe_height != null:
			return maybe_height
	return null

func check_for_sandwich() -> int:
	if items.size() > 2 and items[0].itemtype == "bread" and items[-1].itemtype == "bread":
		var no_doubles_multiplier = 2
		var unique_ingredients = {}
		var last_seen_ingredient = ""
		for i in range(1, items.size() - 1):
			var ingredient_name = items[i].itemtype
			if ingredient_name == last_seen_ingredient:
				no_doubles_multiplier = 0.5
			if not unique_ingredients.has(ingredient_name):
				unique_ingredients[ingredient_name] = true
			last_seen_ingredient = ingredient_name
		return int(1000 * (unique_ingredients.size()) * no_doubles_multiplier + 500 * (items.size() - 2))
	return 0

func celebrate():
	$nonitems/Animation.play("celebrate")

func clear():
	for item in items:
		remove_child(item)
	items.clear()

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
