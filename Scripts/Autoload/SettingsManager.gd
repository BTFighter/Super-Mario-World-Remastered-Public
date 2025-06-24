extends Node

var sprite_settings := {
						"bobomb": 0,
						"bonybeetle": 0,
						"bowser": 0,
						"buzzybeetleshell": 0,
						"drybones": 0,
						"fishbone": 0,
						"galoomba": 0,
						"koopalings": 0,
						"luigi": 0,
						"muncher": 0,
						"peach": 0,
						"pidget": 0,
						"podoboo": 0,
						"spiketop": 0,
						"spiny": 0,
						"yoshi": 0,
						"magikoopa": 0,
						"yoshiswim": 0,
						"yoshiturn": 0,
						"bowserflame": 0,
						"fireball": 0,
						"bubble": 0,
						"snakeblock": 0,
						"coloured_switch_empty": 0,
						"iceblock": 0,
						"coin": 0,
						"motor": 0,
						"onoffswitch": 0,
						"pswitch": 0,
						"door": 0,
						"tileset_colour_style": 0,
						"parachute": 0,
						"lakitucloud": 0,
						"1up": 0,
						"yoshi_berry": 0,
						"signpost": 0,
						"chain_chomp": 0,
						"spike": 0,
						"blooper": 0,
						"angry_sun": 0
						}

@onready var settings_file: Dictionary = settings_template

var settings_template := {
	"resolution": Vector2(1440, 810),
	"window_type": 0,
	"vsync_enabled": false,
	"drop_shadows": false,
	"hud_dragon_coin_style": 0,
	"master_volume": 0.5,
	"music_volume": 0.5,
	"sfx_volume": 0.5,
	"ui_volume": 0.5,
	"modified_life_decrement": false, # false = classic, true = all-players-dead
	"ground_pound": false,
	"air_twirl": false,
	"wall_jump": false,
	"dive": false,
	"air_flutter": false,
	"timer_enabled": false,
	"yoshi_spawn_pause": false,
	"autumn_type": 0,
	"timer_type": 0,
	"level_layout_type": 0,
	"boss_remix": false,
	"sp_collection_style": 0,
	"character_specific_physics": false,
	"soundtrack_type": 0,
	"player_damage_style": 0,
	"coyote_time": false,
	"jump_buffer": true,
	"sprite_settings": sprite_settings,
	"edible_dolphins": false,
	"holding_spin_jump": false,
	"auto_item_drop": true,
	"camera_shake": true,
	}

var raw_file: FileAccess = null

func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg") == false:
		save_settings()
	settings_file = get_file()
	apply_settings(settings_file)

func save_settings() -> void:
	raw_file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	raw_file.store_string(JSON.stringify(settings_file, "\t"))
	raw_file.close()

func get_file():
	raw_file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	var file = JSON.parse_string(raw_file.get_as_text())
	raw_file.close()
	return file

func apply_settings(settings) -> void:
	verify_settings()
	apply_video_settings(settings)
	apply_audio_settings(settings)
	apply_sprite_settings(settings.sprite_settings)

func verify_settings() -> void:
	for i in settings_template.keys():
		if settings_file.has(i) == false:
			settings_file[i] = settings_template[i]
	save_settings()

func apply_video_settings(settings) -> void:
	var res = settings.resolution
	if res is String:
		res = res.replace(")", "")
		res = res.replace("(", "")
		res = res.replace(" ", "")
		res = res.split(",")
		res = Vector2(int(res[0]), int(res[1]))
	DisplayServer.window_set_size(res)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync_enabled else DisplayServer.VSYNC_DISABLED)
	var window_type = int(settings.window_type)
	match window_type: # Sets Window Mode
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MAX, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MAX, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MAX, true)
	await get_tree().process_frame
	center_window()

func apply_sprite_settings(settings) -> void:
	for i in settings.keys():
		sprite_settings[i] = settings[i]

func center_window() -> void:
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)

func apply_audio_settings(settings) -> void:
	var bus_index := 0
	for i in [settings.master_volume, settings.music_volume, settings.sfx_volume, settings.ui_volume]:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(i))
		bus_index += 1
