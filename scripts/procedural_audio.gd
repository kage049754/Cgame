extends Node

const AMBIENCE_ASSET = preload("res://assets/audio/ambience.wav")
const MUSIC_ASSET = preload("res://assets/audio/music.wav")
const CARD_ASSET = preload("res://assets/audio/card.wav")
const WIN_ASSET = preload("res://assets/audio/win.wav")
const LOSS_ASSET = preload("res://assets/audio/loss.wav")
const ITEM_ASSET = preload("res://assets/audio/item.wav")

var ambience_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var effects_player: AudioStreamPlayer
var ambience_stream: AudioStreamWAV
var music_stream: AudioStreamWAV
var card_stream: AudioStreamWAV
var win_stream: AudioStreamWAV
var loss_stream: AudioStreamWAV
var item_stream: AudioStreamWAV

func _ready() -> void:
	ambience_stream = AMBIENCE_ASSET
	ambience_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambience_stream.loop_begin = 0
	ambience_stream.loop_end = ambience_stream.data.size() / 2
	music_stream = MUSIC_ASSET
	music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_stream.loop_begin = 0
	music_stream.loop_end = music_stream.data.size() / 2
	card_stream = CARD_ASSET
	win_stream = WIN_ASSET
	loss_stream = LOSS_ASSET
	item_stream = ITEM_ASSET

	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "AmbiencePlayer"
	ambience_player.volume_db = -28.0
	ambience_player.stream = ambience_stream
	add_child(ambience_player)
	ambience_player.play()

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.volume_db = -30.0
	music_player.stream = music_stream
	add_child(music_player)
	music_player.play()

	effects_player = AudioStreamPlayer.new()
	effects_player.name = "EffectsPlayer"
	effects_player.volume_db = -9.0
	add_child(effects_player)

func set_ambience_volume(value: float) -> void:
	if ambience_player != null:
		ambience_player.volume_db = _volume_to_db(value)

func set_music_volume(value: float) -> void:
	if music_player != null:
		music_player.volume_db = _volume_to_db(value)

func set_effects_volume(value: float) -> void:
	if effects_player != null:
		effects_player.volume_db = _volume_to_db(value)

func _volume_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return linear_to_db(clampf(value, 0.0, 1.0))

func play_card() -> void:
	_play(card_stream)

func play_win() -> void:
	_play(win_stream)

func play_loss() -> void:
	_play(loss_stream)

func play_item() -> void:
	_play(item_stream)

func play_push() -> void:
	_play(item_stream)

func _play(stream: AudioStreamWAV) -> void:
	if effects_player == null or stream == null:
		return
	effects_player.stream = stream
	effects_player.play()
