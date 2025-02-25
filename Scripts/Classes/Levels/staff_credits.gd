extends Level

@onready var player_1: PlayerSpriteDisplay = $Player1
@onready var player_2: PlayerSpriteDisplay = $Player2
@onready var player_3: PlayerSpriteDisplay = $Player3
@onready var yoshi: Node2D = $Yoshi
@onready var player_4: PlayerSpriteDisplay = $Player4
@export_multiline var credits := ""
@onready var eggs := [$Egg1, $Egg2, $Egg3, $Egg4, $Egg5, $Egg6, $Egg7]
var egg_wave := 0.0
const BIG = preload("res://Resources/PlayerPowerUpState/Big.tres")

var bg_index := -1

@onready var peach: Sprite2D = $Yoshi/Peach


const CREDITS_PERSON = preload("res://Instances/UI/credits_person.tscn")
const CREDITS_TITLE = preload("res://Instances/UI/credits_title.tscn")

const peach_textures = [preload("res://Assets/Sprites/Characters/Peach/SNES.png"), preload("res://Assets/Sprites/Characters/Peach/GBA.png"),preload("res://Assets/Sprites/Characters/Peach/Modern.png") ]

const BGS = [preload("res://Assets/Sprites/Backgrounds/Overworld/Rocks/Rock3.png"),
			preload("res://Assets/Sprites/Backgrounds/Overworld/Bushes/Bush4.png"),
			preload("res://Assets/Sprites/Backgrounds/Overworld/Clouds/Clouds1.png"),
			preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/CylMountains.png"),
			preload("res://Assets/Sprites/Backgrounds/Overworld/Rocks/Rock5.png"),
			preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/Mountains1.png"),]
			
const BG_COLOURS = [Color("f8e0b0"),
					Color("f8e0b0"),
					Color("0060b8"),
					Color("183048"),
					Color("98e0e0"),
					Color("f8e0b0")]

func spawn() -> void:
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	print(DirAccess.get_files_at("res://"))
	credits = FileAccess.open("res://credits.txt", FileAccess.READ).get_as_text()
	$Yoshi/Peach.texture = peach_textures[SettingsManager.sprite_settings.peach]
	yoshi.yoshi_animations.play("Move")
	yoshi.yoshi_animations.speed_scale = 2
	print(credits)
	if GameManager.time_played <= (1200):
		AchievementManager.unlock_achievement(preload("res://Resources/Achievements/General/Speedrun.tres"))
	setup_player_sprites()
	setup_credits()
	setup_eggs()
	text_scroll_tween()
	if SaveManager.current_save != null:
		SaveManager.current_save.game_beaten = true
	SaveManager.save_current_file()
	await get_tree().create_timer(95, false).timeout
	TransitionManager.transition_to_level("res://Instances/Levels/epilogue.tscn", self)

func _physics_process(delta: float) -> void:
	if bg_index >= 0 and bg_index < 6:
		$LevelBG.sky_colour = BG_COLOURS[bg_index]
		$LevelBG.main_texture = BGS[bg_index]
	var index := 0
	egg_wave -= 16 * delta
	egg_wave = wrap(egg_wave, 0, PI * 2)
	for i in eggs:
		i.offset.y = sin(egg_wave + index) * 2
		index += 1
	if Input.is_action_pressed("jump_0"):
		Engine.time_scale = 8
	else:
		Engine.time_scale = 1

func text_scroll_tween() -> void:
	for i in 2:
		await get_tree().physics_frame
	var tween = create_tween()
	tween.tween_property($TextContainer, "position:y", -$TextContainer.size.y - 64, 95)
	print($TextContainer.size.y)

func _exit_tree() -> void:
	Engine.time_scale = 1

func setup_player_sprites() -> void:
	var index := 0
	var player_diff = 4 - CoopManager.players_connected
	var players = [player_1, player_2, player_3, player_4]
	for i in CoopManager.players_connected:
		players[i + player_diff].character = CoopManager.player_characters[i]
		players[i + player_diff].power_state = load(CoopManager.player_power_states[i])
	for i in player_diff:
		players[i].hide()

func setup_eggs() -> void:
	for i in 7:
		if SaveManager.current_save != null:
			eggs[i].visible = SaveManager.current_save.eggs_rescued[i]

func setup_credits() -> void:
	for i in credits.split("\n"):
		if i.begins_with("--"):
			var node = CREDITS_TITLE.instantiate()
			node.text = i.replace("--", "")
			$TextContainer.add_child(node)
		else:
			var node = CREDITS_PERSON.instantiate()
			node.text = i
			$TextContainer.add_child(node)

func change_bg() -> void:
	if bg_index >= 6:
		return
	$Animation.play_backwards("new_animation")
	await $Animation.animation_finished
	if bg_index >= 5:
		return
	await get_tree().create_timer(0.1, false).timeout
	bg_index += 1
	$Animation.play("new_animation")
