extends SceneTree

const ZombieScene = preload("res://scenes/zombie_enemy.tscn")

func _initialize() -> void:
	var zombie := ZombieScene.instantiate()
	root.add_child(zombie)
	call_deferred("_verify_animation_playback", zombie)

func _verify_animation_playback(zombie: Node) -> void:
	await process_frame
	var player := zombie.get("animation_player") as AnimationPlayer
	if player == null:
		push_error("Zombie AnimationPlayer was not found.")
		quit(1)
		return
	if not player.is_playing() or player.current_animation != "Idle":
		push_error("Zombie Idle animation did not start.")
		quit(1)
		return
	zombie.call("play_animation", "Idle_Attack")
	if player.current_animation != "Idle_Attack" or not player.is_playing():
		push_error("Zombie Idle_Attack animation did not start.")
		quit(1)
		return
	print("Quaternius Zombie Basic Idle and Idle_Attack animations passed.")
	quit()
