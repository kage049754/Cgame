extends Node3D

const ZOMBIE_MODEL = preload("res://assets/enemies/quaternius_zombie_basic.gltf")

var animation_player: AnimationPlayer

func _ready() -> void:
	var model := ZOMBIE_MODEL.instantiate()
	model.name = "QuaterniusZombieBasic"
	add_child(model)
	animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	play_animation("Idle")

func play_animation(animation_name: String) -> void:
	if animation_player == null:
		return
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
