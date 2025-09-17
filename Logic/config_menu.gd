extends Control

# Settings data structure
var settings = {
	"resolution": Vector2i(1280, 720),
	"fullscreen": false,
	"vsync": true,
	"fps_limit": 60,
	"master_volume": 80
}

# Available resolutions
var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

# Available FPS limits
var fps_limits = [30, 60, 120, 144, 240, 0]  # 0 = unlimited

func _ready():
	create_settings_ui()
	add_background()

func add_background():
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
	background.texture = preload("res://Content/textures/loading screen.png")
	background.expand = true
	background.stretch_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Make the TextureRect fill the entire Control container
	background.anchor_left = 0.0
	background.anchor_right = 1.0
	background.anchor_top = 0.0
	background.anchor_bottom = 1.0
	
	# Add the background to the UI container
	ui_container.add_child(background)

func create_settings_ui():
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.anchor_left = 0.5
	main_container.anchor_right = 0.5
	main_container.anchor_top = 0.5
	main_container.anchor_bottom = 0.5
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title)
	
	# Resolution setting
	create_resolution_setting(main_container)
	
	# Window mode setting
	create_window_mode_setting(main_container)
	
	# VSync setting
	create_vsync_setting(main_container)
	
	# FPS Limit setting
	create_fps_limit_setting(main_container)
	
	# Volume setting
	create_volume_setting(main_container)
	
	# Apply button
	var apply_button = Button.new()
	apply_button.text = "APPLY SETTINGS"
	apply_button.pressed.connect(apply_settings)
	main_container.add_child(apply_button)

func create_resolution_setting(container: VBoxContainer):
	var resolution_container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = "Resolution:"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resolution_container.add_child(label)
	
	var option_button = OptionButton.new()
	for resolution in resolutions:
		option_button.add_item("%d x %d" % [resolution.x, resolution.y])
	
	# Set current resolution
	var current_index = resolutions.find(settings.resolution)
	if current_index != -1:
		option_button.select(current_index)
	
	option_button.item_selected.connect(func(index):
		settings.resolution = resolutions[index]
	)
	resolution_container.add_child(option_button)
	
	container.add_child(resolution_container)

func create_window_mode_setting(container: VBoxContainer):
	var window_container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = "Window Mode:"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	window_container.add_child(label)
	
	var option_button = OptionButton.new()
	option_button.add_item("Windowed")
	option_button.add_item("Fullscreen")
	option_button.add_item("Borderless")
	
	option_button.select(0 if not settings.fullscreen else 1)
	option_button.item_selected.connect(func(index):
		settings.fullscreen = (index > 0)
	)
	window_container.add_child(option_button)
	
	container.add_child(window_container)

func create_vsync_setting(container: VBoxContainer):
	var vsync_container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = "VSync:"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vsync_container.add_child(label)
	
	var check_button = CheckBox.new()
	check_button.button_pressed = settings.vsync
	check_button.toggled.connect(func(toggled):
		settings.vsync = toggled
	)
	vsync_container.add_child(check_button)
	
	container.add_child(vsync_container)

func create_fps_limit_setting(container: VBoxContainer):
	var fps_container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = "FPS Limit:"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fps_container.add_child(label)
	
	var option_button = OptionButton.new()
	for limit in fps_limits:
		option_button.add_item("Unlimited" if limit == 0 else str(limit) + " FPS")
	
	# Set current FPS limit
	var current_index = fps_limits.find(settings.fps_limit)
	if current_index != -1:
		option_button.select(current_index)
	
	option_button.item_selected.connect(func(index):
		settings.fps_limit = fps_limits[index]
	)
	fps_container.add_child(option_button)
	
	container.add_child(fps_container)

func create_volume_setting(container: VBoxContainer):
	var volume_container = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Master Volume: %d%%" % settings.master_volume
	volume_container.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.value = settings.master_volume
	slider.value_changed.connect(func(value):
		settings.master_volume = value
		label.text = "Master Volume: %d%%" % value
		# Update volume immediately
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))
	)
	volume_container.add_child(slider)
	
	container.add_child(volume_container)

func apply_settings():
	# Apply resolution and window mode
	var window = get_window()
	window.size = settings.resolution
	window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if settings.fullscreen else Window.MODE_WINDOWED
	
	# Apply VSync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)
	
	# Apply FPS limit
	Engine.max_fps = settings.fps_limit
	
	# Apply volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.master_volume / 100.0))
	
	# Save settings (you can implement saving to file)
	save_settings()
	
	print("Settings applied!")

func save_settings():
	# Save to file (basic example)
	var config = ConfigFile.new()
	config.set_value("video", "resolution", settings.resolution)
	config.set_value("video", "fullscreen", settings.fullscreen)
	config.set_value("video", "vsync", settings.vsync)
	config.set_value("video", "fps_limit", settings.fps_limit)
	config.set_value("audio", "master_volume", settings.master_volume)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		settings.resolution = config.get_value("video", "resolution", Vector2i(1280, 720))
		settings.fullscreen = config.get_value("video", "fullscreen", false)
		settings.vsync = config.get_value("video", "vsync", true)
		settings.fps_limit = config.get_value("video", "fps_limit", 60)
		settings.master_volume = config.get_value("audio", "master_volume", 80)
