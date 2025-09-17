extends Node2D

func _ready():
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://Content/textures/grids/white_grid_on_black.png") 

	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED 
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, Vector2(5000, 5000)) 

	sprite.z_index = -100
	add_child(sprite)
	# Create a CanvasLayer for UI elements
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 0  # Base layer for UI
	add_child(ui_layer)
	
	# Create a Control node that will contain our UI
	var ui_container = Control.new()
	ui_layer.add_child(ui_container)
	
	# Set the Control node to fill the entire screen
	ui_container.anchor_left = 0.0
	ui_container.anchor_right = 1.0
	ui_container.anchor_top = 0.0
	ui_container.anchor_bottom = 1.0
	
	# Create fullscreen background TextureRect
	var background = TextureRect.new()
	background.texture = preload("res://Content/textures/ui.png")
	background.expand = true
	background.stretch_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	
	# Make the TextureRect fill the entire Control container
	background.anchor_left = 0.0
	background.anchor_right = 1.0
	background.anchor_top = 0.0
	background.anchor_bottom = 1.0
	
	# Add the background to the UI container
	ui_container.add_child(background)
	
