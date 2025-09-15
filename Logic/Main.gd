extends Node2D

func _ready():
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://Content/textures/grids/white_grid_on_black.png") 

	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED 
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, Vector2(5000, 5000)) 

	sprite.z_index = -100
	add_child(sprite)
