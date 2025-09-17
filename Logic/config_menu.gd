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
	# Set the control to fill the entire screen
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0
	
	load_settings()
	create_settings_ui()

func create_settings_ui():
	# Create main margin container for left alignment
	var margin_container = MarginContainer.new()
	margin_container.anchor_left = 0.0
	margin_container.anchor_right = 1.0
	margin_container.anchor_top = 0.0
	margin_container.anchor_bottom = 1.0
	margin_container.add_theme_constant_override("margin_left", 100)
	margin_container.add_theme_constant_override("margin_top", 80)
	margin_container.add_theme_constant_override("margin_right", 100)
	add_child(margin_container)
	
	# Main vertical container - NO CenterContainer!
	var main_container = VBoxContainer.new()
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN  # Align to top
	main_container.add_theme_constant_override("separation", 40)
	margin_container.add_child(main_container)
	
	# Title - left aligned
	var title = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 36)
	title.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	main_container.add_child(title)
	
	# Add spacer
	var title_spacer = Control.new()
	title_spacer.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(title_spacer)
	
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
	
	# Add large spacer before buttons
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(0, 60)
	main_container.add_child(button_spacer)
	
	# Apply button - left aligned
	var apply_button = Button.new()
	apply_button.text = "APPLY SETTINGS"
	apply_button.pressed.connect(apply_settings)
	apply_button.custom_minimum_size = Vector2(300, 60)
	apply_button.add_theme_font_size_override("font_size", 24)
	apply_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	main_container.add_child(apply_button)
	
	# Button spacer
	var button_gap = Control.new()
	button_gap.custom_minimum_size = Vector2(0, 20)
	main_container.add_child(button_gap)
	
	# Back button - left aligned
	var back_button = Button.new()
	back_button.text = "BACK"
	back_button.pressed.connect(go_back)
	back_button.custom_minimum_size = Vector2(300, 60)
	back_button.add_theme_font_size_override("font_size", 24)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	main_container.add_child(back_button)

func create_resolution_setting(container: VBoxContainer):
	var setting_container = VBoxContainer.new()
	setting_container.add_theme_constant_override("separation", 15)
	setting_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var label = Label.new()
	label.text = "RESOLUTION"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(label)
	
	var option_container = HBoxContainer.new()
	option_container.add_theme_constant_override("separation", 20)
	option_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var option_button = OptionButton.new()
	option_button.custom_minimum_size = Vector2(300, 50)
	option_button.add_theme_font_size_override("font_size", 20)
	for resolution in resolutions:
		option_button.add_item("%d x %d" % [resolution.x, resolution.y])
	
	# Set current resolution
	var current_index = resolutions.find(settings.resolution)
	if current_index == -1:
		current_index = 0
	option_button.select(current_index)
	
	option_button.item_selected.connect(func(index):
		settings.resolution = resolutions[index]
	)
	option_container.add_child(option_button)
	setting_container.add_child(option_container)
	
	container.add_child(setting_container)

func create_window_mode_setting(container: VBoxContainer):
	var setting_container = VBoxContainer.new()
	setting_container.add_theme_constant_override("separation", 15)
	setting_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var label = Label.new()
	label.text = "WINDOW MODE"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(label)
	
	var option_container = HBoxContainer.new()
	option_container.add_theme_constant_override("separation", 20)
	option_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var option_button = OptionButton.new()
	option_button.custom_minimum_size = Vector2(300, 50)
	option_button.add_theme_font_size_override("font_size", 20)
	option_button.add_item("Windowed")
	option_button.add_item("Fullscreen")
	option_button.add_item("Borderless")
	
	option_button.select(0 if not settings.fullscreen else 1)
	option_button.item_selected.connect(func(index):
		settings.fullscreen = (index > 0)
	)
	option_container.add_child(option_button)
	setting_container.add_child(option_container)
	
	container.add_child(setting_container)

func create_vsync_setting(container: VBoxContainer):
	var setting_container = VBoxContainer.new()
	setting_container.add_theme_constant_override("separation", 15)
	setting_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var label = Label.new()
	label.text = "VSYNC"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(label)
	
	var check_container = HBoxContainer.new()
	check_container.add_theme_constant_override("separation", 20)
	check_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var check_button = CheckBox.new()
	check_button.custom_minimum_size = Vector2(30, 30)
	check_button.button_pressed = settings.vsync
	check_button.toggled.connect(func(toggled):
		settings.vsync = toggled
	)
	check_container.add_child(check_button)
	
	var check_label = Label.new()
	check_label.text = "Enabled"
	check_label.add_theme_font_size_override("font_size", 20)
	check_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	check_container.add_child(check_label)
	
	setting_container.add_child(check_container)
	container.add_child(setting_container)

func create_fps_limit_setting(container: VBoxContainer):
	var setting_container = VBoxContainer.new()
	setting_container.add_theme_constant_override("separation", 15)
	setting_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var label = Label.new()
	label.text = "FPS LIMIT"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(label)
	
	var option_container = HBoxContainer.new()
	option_container.add_theme_constant_override("separation", 20)
	option_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var option_button = OptionButton.new()
	option_button.custom_minimum_size = Vector2(300, 50)
	option_button.add_theme_font_size_override("font_size", 20)
	for limit in fps_limits:
		option_button.add_item("Unlimited" if limit == 0 else str(limit) + " FPS")
	
	# Set current FPS limit
	var current_index = fps_limits.find(settings.fps_limit)
	if current_index == -1:
		current_index = 1
	option_button.select(current_index)
	
	option_button.item_selected.connect(func(index):
		settings.fps_limit = fps_limits[index]
	)
	option_container.add_child(option_button)
	setting_container.add_child(option_container)
	
	container.add_child(setting_container)

func create_volume_setting(container: VBoxContainer):
	var setting_container = VBoxContainer.new()
	setting_container.add_theme_constant_override("separation", 15)
	setting_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	
	var label = Label.new()
	label.text = "MASTER VOLUME"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(label)
	
	var value_label = Label.new()
	value_label.text = "%d%%" % settings.master_volume
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	value_label.add_theme_font_size_override("font_size", 20)
	value_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	setting_container.add_child(value_label)
	
	var slider = HSlider.new()
	slider.custom_minimum_size = Vector2(400, 40)
	slider.min_value = 0
	slider.max_value = 100
	slider.value = settings.master_volume
	slider.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # Left align
	slider.value_changed.connect(func(value):
		settings.master_volume = value
		value_label.text = "%d%%" % value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))
	)
	setting_container.add_child(slider)
	
	container.add_child(setting_container)

func apply_settings():
	# Apply resolution and window mode
	var window = get_window()
	window.size = settings.resolution
	
	if settings.fullscreen:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		window.position = (DisplayServer.screen_get_size() - settings.resolution) / 2
	
	# Apply VSync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)
	
	# Apply FPS limit
	Engine.max_fps = settings.fps_limit
	
	# Save settings
	save_settings()
	
	print("Settings applied!")

func go_back():
	SceneManager.switch_scene("res://Scenes/MainMenu.tscn")

func save_settings():
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
