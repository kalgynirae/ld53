extends Node3D


var stacks: Array[Stack]
var active_stack: int

# Called when the node enters the scene tree for the first time.
func _ready():
	active_stack = 0
	for table in get_children():
		if table.name.begins_with("Table"):
			for stack in table.get_children():
				if stack.name.begins_with("Stack"):
					stacks.push_back(stack)
					stack.deactivate()
	stacks[active_stack].activate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
