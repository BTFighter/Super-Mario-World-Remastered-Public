extends PlayerState

var can_fall := false


func enter(_msg := {}) -> void:
	var use_modified: bool = SettingsManager.settings_file.get("modified_life_decrement", false)
	player.dead = true
	can_fall = false
	var camera_pos_save := player.camera.get_target_position()
	player.sprite.show()
	player.sprite.rotation = 0
	CoopManager.alive_players.erase(player.player_id)
	player.hitbox_area.set_deferred("monitorable",false)
	player.hitbox_area.set_deferred("monitoring",false)
	player.camera.top_level = true
	player.camera.make_current()
	player.camera.global_position = camera_pos_save
	player.camera.align()
	player.carried = false
	player.velocity = Vector2.ZERO
	player.sprite.speed_scale = 2
	player.sprite_speed_scale = 2
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	CoopManager.dead_players[player.player_id] = player
	if CoopManager.coop_enabled:
		if use_modified:
			if CoopManager.alive_players.size() != 0:
				multi_dead(false)
			else:
				end_dead(true)
		else:
			if CoopManager.alive_players.size() != 0:
				multi_dead(true)
			else:
				end_dead(true)
	else:
		end_dead(true)
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	player.velocity.y = -200
	can_fall = true

func fast_dead() -> void:
	get_tree().paused = true
	player.play_global_sfx("fast_death")
	await get_tree().create_timer(0.5, true).timeout
	player.set_power_state(player.small_power_state)
	TransitionManager.death_load()
	

func end_dead(decrement_life := true) -> void:
	if player.fast_death:
		fast_dead()
		return
	GameManager.all_players_dead.emit()
	CoopManager.game_overed_players = {}
	CoopManager.dead_players = {}
	MusicPlayer.set_music_override(load(player.get_sfx("full_death")), 10)
	get_tree().paused = true
	await get_tree().create_timer(2.5).timeout
	player.set_power_state(player.small_power_state)
	await get_tree().physics_frame
	if GameManager.lives > 1:
		if GameManager.inf_lives == false and decrement_life:
			GameManager.lives -= 1
		if GameManager.time <= 0:
			GameManager.time_out()
		else:
			TransitionManager.death_load()
	else:
		player.game_over()

func multi_dead(decrement_life := true) -> void:
	player.play_global_sfx("fast_death")
	if GameManager.inf_lives == false and decrement_life:
		GameManager.lives -= 1
	await get_tree().create_timer(3).timeout
	if GameManager.lives <= 0:
		CoopManager.game_overed_players[player.player_id] = player
		player.remove_from_game()
		return
	if is_instance_valid(CoopManager.get_first_alive_player()) == false:
		return
	player.bubble_respawn()

func exit() -> void:
	player.set_power_state(player.small_power_state)
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.z_index = 0
	player.scale = Vector2.ONE
	player.camera.top_level = false
	player.camera.position = Vector2.ZERO

func physics_update(_delta: float) -> void:
	player.z_index = 100
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)
	player.current_animation = "Dead"
	player.sprite.play("Dead")
	if can_fall:
		player.velocity.y += 10
	else:
		player.velocity = Vector2.ZERO
	player.velocity.y = clamp(player.velocity.y, -9999, 270)
