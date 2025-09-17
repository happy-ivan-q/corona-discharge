extends Node

var current_scene: Node = null
var loading_screen: TextureRect = null

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	create_loading_screen()

func switch_scene(scene_path: String) -> void:
	show_loading_screen()
	call_deferred("_load_scene", scene_path)

func _load_scene(scene_path: String) -> void:
	# Load the new scene
	var new_scene_resource = load(scene_path)
	
	if new_scene_resource:
		var new_scene = new_scene_resource.instantiate()
		
		# Remove current scene
		current_scene.queue_free()
		
		# Add new scene
		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene
		current_scene = new_scene
		
		# Hide loading screen after brief delay
		await get_tree().create_timer(0.5).timeout
		hide_loading_screen()
	else:
		push_error("Failed to load scene: " + scene_path)
		hide_loading_screen()

func show_loading_screen() -> void:
	if loading_screen:
		loading_screen.visible = true

func hide_loading_screen() -> void:
	if loading_screen:
		loading_screen.visible = false

func create_loading_screen() -> void:
	# Create CanvasLayer for loading screen
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Top layer
	canvas_layer.name = "LoadingScreenLayer"
	get_tree().root.add_child(canvas_layer)
	
	# Create TextureRect loading screen
	loading_screen = TextureRect.new()
	loading_screen.texture = preload("res://Content/textures/loading screen.png")
	loading_screen.expand = true
	loading_screen.stretch_mode = TextureRect.STRETCH_SCALE
	loading_screen.anchor_left = 0.0
	loading_screen.anchor_right = 1.0
	loading_screen.anchor_top = 0.0
	loading_screen.anchor_bottom = 1.0
	loading_screen.visible = false
	
	canvas_layer.add_child(loading_screen)
