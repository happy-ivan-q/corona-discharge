extends CharacterBody2D

@export var speed = 400
var grid_size = 20
var placed_blocks = []
var placed_block_positions = []
var placed_block_types = []
var target = position
var block
var GRID_SIZE = 20
var previous_position = Vector2(0,0)
var input_direction
var right_down = false
var left_down = false
var root_pos = Vector2(0,0)
var DoneOnce1 = false
var visited = []
var count = 0
var freq = 50
var txstate = 1
var hanging_blocks = []

# Preload textures to avoid loading them every frame
var drone_textures = {
	"state1": preload("res://Content/textures/drone/drone_state1.png"),
	"state2": preload("res://Content/textures/drone/drone_state2.png"),
	"state1_place": preload("res://Content/textures/drone/drone_state1_place.png"),
	"state2_place": preload("res://Content/textures/drone/drone_state2_place.png")
}

func _ready() -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://Content/textures/bg.png")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.expand = true
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	add_child(bg)
	$Icon.texture = drone_textures.state1

func _input(event):
	if event.is_action_pressed("right_click"):
		right_down = true
	if event.is_action_released("right_click"):
		right_down = false
	if event.is_action_pressed("left_click"):
		left_down = true
	if event.is_action_released("left_click"):
		left_down = false
	input_direction = Input.get_vector("left", "right", "up", "down")
	previous_position = snap(get_global_mouse_position())

func _process(delta: float) -> void:
	var current_mouse_pos = get_global_mouse_position()
	$"../FadingGrid".position = snap(current_mouse_pos)
	target = current_mouse_pos

	right_down = Input.is_action_pressed("right_click")
	left_down = Input.is_action_pressed("left_click")
	
	if right_down:
		block_place(current_mouse_pos, get_tree().current_scene.get_node("Camera2D").get_node("Control").selected_part_id)
	if left_down:
		block_unplace(current_mouse_pos)
	previous_position = snap(get_global_mouse_position())

func _physics_process(delta):
	handle_states()
	velocity = position.direction_to(target) * speed
	look_at(target)
	if position.distance_to(target) > 50:
		move_and_slide()
	if position.distance_to(target) < 50:
		velocity = - speed * position.direction_to(get_global_mouse_position())
		move_and_slide()
		get_tree().current_scene.get_node("Camera2D").position = get_tree().current_scene.get_node("Camera2D").position + input_direction * speed * delta
	
func handle_states():
	count += 1
	if count % freq == 0:
		if txstate == 1:
			txstate = 2
			$Icon.texture = drone_textures.state2
		else:
			txstate = 1
			$Icon.texture = drone_textures.state1
	
	if right_down or left_down:
		if txstate == 1:
			$Icon.texture = drone_textures.state1_place
		else:
			$Icon.texture = drone_textures.state2_place
	else:
		if txstate == 1:
			$Icon.texture = drone_textures.state1
		else:
			$Icon.texture = drone_textures.state2

func reaches_root(start_pos: Vector2) -> bool:
	var queue = []
	var visited = []
	
	var start = snap(start_pos)
	queue.append(start)
	visited.append(start)
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == root_pos:
			return true
		
		var directions = [
			Vector2(0, GRID_SIZE),
			Vector2(GRID_SIZE, 0),
			Vector2(0, -GRID_SIZE),
			Vector2(-GRID_SIZE, 0)
		]
		
		for direction in directions:
			var next_pos = current + direction
			if next_pos in visited:
				continue
			if next_pos in placed_block_positions:
				queue.append(next_pos)
				visited.append(next_pos)
	
	return false

func block_place(pos: Vector2, block_id: int):
	if placed_block_positions.is_empty():
		DoneOnce1 = false
	if not DoneOnce1:
		DoneOnce1 = true
		root_pos = snap(pos)
		print(str(root_pos.x) + str(root_pos.y) + "is set as the root")
	
	# Check if adjacent to existing blocks or if it's the first block
	var snapped_pos = snap(pos)
	if placed_block_positions.is_empty() or \
	   Vector2(snapped_pos.x, snapped_pos.y + GRID_SIZE) in placed_block_positions or \
	   Vector2(snapped_pos.x, snapped_pos.y - GRID_SIZE) in placed_block_positions or \
	   Vector2(snapped_pos.x - GRID_SIZE, snapped_pos.y) in placed_block_positions or \
	   Vector2(snapped_pos.x + GRID_SIZE, snapped_pos.y) in placed_block_positions or \
		true:
		
		if not snapped_pos in placed_block_positions: 
			var block = Sprite2D.new()
			block.position = Vector2(snapped_pos.x + 0.5 * GRID_SIZE, snapped_pos.y + 0.5 * GRID_SIZE)
			placed_block_positions.append(snapped_pos)
			block.texture = get_tree().current_scene.get_node("Camera2D").get_node("Control").part_textures[get_tree().current_scene.get_node("Camera2D").get_node("Control").selected_part_id]
			placed_blocks.append(block)
			placed_block_types.append(get_tree().current_scene.get_node("Camera2D").get_node("Control").part_names[get_tree().current_scene.get_node("Camera2D").get_node("Control").selected_part_id])
			get_tree().current_scene.add_child(block)
	
func block_unplace(pos: Vector2):
	var snapped_pos = snap(pos)
	var block_removal_id = placed_block_positions.find(snapped_pos)
	if block_removal_id == -1: 
		return
	
	print("removing " + str(placed_blocks[block_removal_id]) + " at " + str(placed_block_positions[block_removal_id]))
	placed_blocks[block_removal_id].queue_free()
	placed_blocks.remove_at(block_removal_id)
	placed_block_positions.remove_at(block_removal_id)
	placed_block_types.remove_at(block_removal_id)
	
	# Check for hanging blocks after removal
	check_hanging_blocks()
	
func check_hanging_blocks():
	var positions_to_check = placed_block_positions.duplicate()
	
	for pos in positions_to_check:
		# Skip if this position was already removed
		if not pos in placed_block_positions:
			continue
			
		if not reaches_root(pos):
			# Find the index again since arrays may have changed
			var index = placed_block_positions.find(pos)
			if index != -1:
				#print("Removing hanging block at ", pos)
				#block_unplace(pos)
				hanging_blocks.append(pos)
				
	
func snap(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / GRID_SIZE) * GRID_SIZE, floor(pos.y / GRID_SIZE) * GRID_SIZE)
