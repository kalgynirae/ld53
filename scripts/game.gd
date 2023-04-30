extends Node3D

var stacks: Array[Stack]
var active_stack: int
var active_item: Node
var score: int = 0
var started: bool = false

var Bread = preload("res://scenes/bread.tscn")
var Donut = preload("res://scenes/donut.tscn")
var FriedEgg = preload("res://scenes/fried_egg.tscn")
var Ham = preload("res://scenes/ham.tscn")
var Tomato = preload("res://scenes/tomato.tscn")

func start():
	active_stack = 0
	for table in get_children():
		if table.name.begins_with("Table"):
			for stack in table.get_children():
				if stack.name.begins_with("Stack"):
					stacks.push_back(stack)
	stacks[active_stack].activate()
	active_item = null
	$Camera3D/CameraAnimation.play("pan_in")
	%Music.playing = true
	%Bells.playing = true
	started = true

func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	if not started:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			start()
	else:
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

func _input(event):
	if started:
		if event is InputEventMouseButton and event.is_pressed():
			var viewport_size = get_viewport().get_visible_rect().size
			var two_thirds_height = viewport_size.y * 2 / 3
			if event.position.y > two_thirds_height:
				var one_third_width = viewport_size.x / 3
				var stacki = floor(event.position.x / one_third_width)
				print("Mouse Click/Unclick at: ", event.position, " stack ", stacki)

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
			%CelebrationAnimation.play("celebrate")
			stack.celebrate()
			stack.clear()
			refill(stack)
		score += new_score
	%ScorePanel/%ScoreText.text = format_number(score)

func refill(completed_stack):
	var counts = {}
	var total_ingredients = 0
	for stack in stacks:
		for item in stack.items:
			if not counts.has(item.itemtype):
				counts[item.itemtype] = 0
			counts[item.itemtype] += 1
			total_ingredients += 1
	if total_ingredients > 0:
		for i in range(2):
			var bread = Bread.instantiate()
			completed_stack.spawn(bread)
	else:
		for i in range(2):
			var stacki = randi() % stacks.size()
			var bread = Bread.instantiate()
			stacks[stacki].spawn(bread)
		for i in range(randi() % 3 + 5):
			var possible = [FriedEgg, Ham, Tomato]
			var newitem = possible[randi() % possible.size()].instantiate()
			stacks[randi() % stacks.size()].spawn(newitem)

func format_number(n: int) -> String:
	if n < 1000:
		return str(n)
	var formatted = ""
	while n >= 1000:
		formatted = ",%03d%s" % [n % 1000, formatted]
		n /= 1000
	return "%d%s" % [n, formatted]
