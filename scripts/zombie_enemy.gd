extends Node3D

const ZOMBIE_MODEL = preload("res://assets/enemies/quaternius_zombie_basic.gltf")

var animation_player: AnimationPlayer
var threat_level := 0
var rest_position := Vector3.ZERO
var target_position := Vector3.ZERO
var movement_tween: Tween

const MAX_THREAT_LEVEL := 3
const THREAT_STEP := Vector3(0.42, 0.0, 0.22)

func _ready() -> void:
	rest_position = position
	target_position = position
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
			threat_level = maxi(0, threat_level - 1)
			play_animation("Death" if run_ending == "victory" else "HitReact")
		"lose":
			threat_level = mini(MAX_THREAT_LEVEL, threat_level + 1)
			play_animation("Punch")
		"push":
			threat_level = mini(MAX_THREAT_LEVEL, threat_level + 1)
			play_animation("Idle_Attack")
		_:
			play_animation("Idle")
	if run_ending == "victory":
		threat_level = 0
		target_position = rest_position + Vector3(0.0, 0.0, -1.25)
	elif run_ending == "defeat":
		target_position = rest_position + Vector3(1.4, 0.0, 0.7)
	else:
		target_position = position_for_threat(rest_position, threat_level)
	_animate_approach(target_position)

static func position_for_threat(origin: Vector3, level: int) -> Vector3:
	return origin + THREAT_STEP * clampi(level, 0, MAX_THREAT_LEVEL)

func _animate_approach(destination: Vector3) -> void:
	if movement_tween != null and movement_tween.is_running():
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	movement_tween.tween_property(self, "position", destination, 0.55)

func play_animation(animation_name: String) -> void:
	if animation_player == null:
		return
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
