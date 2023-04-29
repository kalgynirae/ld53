extends Node3D

var stacks: Array[Stack]
var active_stack: int
var active_item: Node

func _ready():
	active_stack = 0
	for table in get_children():
		if table.name.begins_with("Table"):
			for stack in table.get_children():
				if stack.name.begins_with("Stack"):
					stacks.push_back(stack)
					stack.deactivate()
	stacks[active_stack].activate()
	active_item = null

func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_right"):
		stacks[active_stack].deactivate()
		active_stack = (active_stack + 1) % stacks.size()
		stacks[active_stack].activate()
	if Input.is_action_just_pressed("ui_left"):
		stacks[active_stack].deactivate()
		active_stack = (active_stack - 1) % stacks.size()
		stacks[active_stack].activate()
	if Input.is_action_just_pressed("ui_up"):
		if active_item == null:
			var item = stacks[active_stack].pop()
			if item != null:
				item.position.y = 0.5
				active_item = item
	if Input.is_action_just_pressed("ui_down"):
		if active_item != null:
			var active_parent = active_item.get_parent()
			if stacks[active_stack] != active_parent:
				var global_pos = active_item.global_position
				active_parent.remove_child(active_item)
				stacks[active_stack].add_child(active_item)
				active_item.position = stacks[active_stack].to_local(global_pos)
			stacks[active_stack].push(active_item)
			active_item = null
