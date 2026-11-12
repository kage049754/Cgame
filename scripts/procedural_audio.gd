extends Node

const SAMPLE_RATE := 22050

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
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "AmbiencePlayer"
	ambience_player.volume_db = -28.0
	ambience_stream = _make_ambience()
	ambience_player.stream = ambience_stream
	add_child(ambience_player)
	ambience_player.play()

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.volume_db = -30.0
	music_stream = _make_music()
	music_player.stream = music_stream
	add_child(music_player)
	music_player.play()

	effects_player = AudioStreamPlayer.new()
	effects_player.name = "EffectsPlayer"
	effects_player.volume_db = -9.0
	add_child(effects_player)
	card_stream = _make_effect(0.12, 540.0, 260.0, 0.28)
	win_stream = _make_effect(0.72, 420.0, 920.0, 0.24)
	loss_stream = _make_effect(0.7, 190.0, 72.0, 0.22)
	item_stream = _make_effect(0.42, 660.0, 1040.0, 0.2)

func _make_ambience() -> AudioStreamWAV:
	var duration := 8.0
	var sample_count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var time := float(i) / SAMPLE_RATE
		var pulse := 0.78 + 0.22 * sin(TAU * 0.125 * time)
		var sample := (
			sin(TAU * 42.0 * time) * 0.11
			+ sin(TAU * 57.0 * time) * 0.06
			+ sin(TAU * 83.0 * time) * 0.025
		) * pulse
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream

func _make_music() -> AudioStreamWAV:
	var duration := 8.0
	var segment_duration := 2.0
	var chords := [
		[146.83, 174.61, 220.0],
		[116.54, 146.83, 174.61],
		[174.61, 220.0, 261.63],
		[130.81, 164.81, 196.0]
	]
	var sample_count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var time := float(i) / SAMPLE_RATE
		var segment := int(time / segment_duration) % chords.size()
		var segment_time := fposmod(time, segment_duration)
		var edge := minf(segment_time, segment_duration - segment_time)
		var fade := clampf(edge / 0.28, 0.0, 1.0)
		fade = fade * fade * (3.0 - 2.0 * fade)
		var chord: Array = chords[segment]
		var pad := 0.0
		for frequency in chord:
			pad += sin(TAU * float(frequency) * time) / float(chord.size())
		var bass := sin(TAU * 55.0 * time) * 0.07
		var pulse := 0.88 + 0.12 * sin(TAU * 0.25 * time)
		var bell_time := fposmod(time, segment_duration)
		var bell := sin(TAU * 523.25 * bell_time) * exp(-bell_time * 3.8) * 0.018
		var sample := ((pad * 0.13 + bass) * fade + bell) * pulse
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream

func _make_effect(duration: float, start_frequency: float, end_frequency: float, volume: float) -> AudioStreamWAV:
	var sample_count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var phase := 0.0
	for i in range(sample_count):
		var time := float(i) / SAMPLE_RATE
		var progress := float(i) / maxf(1.0, float(sample_count - 1))
		var frequency := lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / SAMPLE_RATE
		var envelope := exp(-time * (5.5 if duration > 0.3 else 24.0))
		var sample := sin(phase) * volume * envelope
		if duration < 0.2:
			sample += sin(TAU * 1450.0 * time) * 0.045 * exp(-time * 45.0)
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream

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
