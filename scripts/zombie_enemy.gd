extends Node3D

const ZOMBIE_MODEL = preload("res://assets/enemies/quaternius_zombie_basic.gltf")

var animation_player: AnimationPlayer

func _ready() -> void:
	var model := ZOMBIE_MODEL.instantiate()
	model.name = "QuaterniusZombieBasic"
	add_child(model)
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		push_error("Quaternius Zombie Basic did not import an AnimationPlayer.")
		return
	animation_player = players[0] as AnimationPlayer
	play_animation("Idle")

func play_outcome(result: String, run_ending: String) -> void:
	match result:
		"win":
			play_animation("Death" if run_ending == "victory" else "HitReact")
		"lose":
			play_animation("Punch")
		"push":
			play_animation("Idle_Attack")
		_:
			play_animation("Idle")

func play_animation(animation_name: String) -> void:
	if animation_player == null:
		return
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
