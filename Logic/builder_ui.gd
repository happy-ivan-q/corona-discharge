extends Control


var part_textures= [load("res://Content/textures/Hull.png")]
var part_names = ["hull"]
var selected_part_id = 0
var part_count = 1
var font_color = Color.WHITE


func _input(event):
	
	if event.is_action_released("ui_up"):
		selected_part_id += 1
	elif event.is_action_released("ui_down"):
		selected_part_id -= 1
	if selected_part_id < 0:
		selected_part_id = part_count - 1
	if selected_part_id > part_count - 1:
		selected_part_id = 0
	var partlist = ""
	for i in get_tree().current_scene.get_node("Builder").get_node("CharacterBody2D").placed_block_types:
		partlist += i
		partlist += "\n"
	
