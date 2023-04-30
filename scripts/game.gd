extends Node3D

var stacks: Array[Stack]
var active_stack: int
var active_item: Node
var score: int = 0

func _ready():
	active_stack = 0
	for table in get_children():
		if table.name.begins_with("Table"):
			for stack in table.get_children():
				if stack.name.begins_with("Stack"):
					stacks.push_back(stack)
	stacks[active_stack].activate()
	active_item = null
	$Camera3D/CameraAnimation.play("pan_in")

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
		pick_up()
	if Input.is_action_just_pressed("ui_down"):
		put_down()

func pick_up():
	if active_item == null:
		var item = stacks[active_stack].pop()
		if item != null:
			var tween = get_tree().create_tween()
			$pickup.play()
			tween.tween_property(item, "position:y", 0.5, 0.1)
			active_item = item

func put_down():
	if active_item != null:
		$putdown.play()
		var active_parent = active_item.get_parent()
		if stacks[active_stack] != active_parent:
			var global_pos = active_item.global_position
			active_parent.remove_child(active_item)
			stacks[active_stack].add_child(active_item)
			active_item.position = stacks[active_stack].to_local(global_pos)
		stacks[active_stack].push(active_item)
		active_item = null
	check_and_score()

func check_and_score():
	for stack in stacks:
		var new_score = stack.check_for_sandwich()
		if new_score > 0:
			stack.celebrate()
		score += new_score
	%ScorePanel/%ScoreText.text = format_number(score)

func format_number(n: int) -> String:
	if n < 1000:
		return str(n)
	var formatted = ""
	while n >= 1000:
		formatted = ",%03d%s" % [n % 1000, formatted]
		n /= 1000
	return "%d%s" % [n, formatted]
