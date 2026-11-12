extends SceneTree

const AudioSystemScript = preload("res://scripts/procedural_audio.gd")

func _initialize() -> void:
	var audio_system := AudioSystemScript.new()
	root.add_child(audio_system)
	call_deferred("_verify_audio", audio_system)

func _verify_audio(audio_system: Node) -> void:
	await process_frame
	var ambience := audio_system.get("ambience_stream") as AudioStreamWAV
	var music := audio_system.get("music_stream") as AudioStreamWAV
	var card := audio_system.get("card_stream") as AudioStreamWAV
	var win := audio_system.get("win_stream") as AudioStreamWAV
	var loss := audio_system.get("loss_stream") as AudioStreamWAV
	var item := audio_system.get("item_stream") as AudioStreamWAV
	if ambience == null or music == null or card == null or win == null or loss == null or item == null:
		push_error("One or more pre-rendered audio resources failed to load.")
		quit(1)
		return
	if ambience.data.size() < 300000 or ambience.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		push_error("Ambient WAV is missing data or loop configuration.")
		quit(1)
		return
	if music.data.size() < 300000 or music.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		push_error("Music WAV is missing data or loop configuration.")
		quit(1)
		return
	if card.data.size() < 1000 or win.data.size() < 10000 or loss.data.size() < 10000 or item.data.size() < 5000:
		push_error("One or more sound-effect WAV resources are empty or incomplete.")
		quit(1)
		return
	if music.mix_rate != 22050 or ambience.mix_rate != 22050:
		push_error("Ambient and music WAV sample rates should be 22050 Hz.")
		quit(1)
		return
	print("All six pre-rendered original audio resources passed.")
	quit()
