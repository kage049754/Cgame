extends SceneTree

const AudioSystemScript = preload("res://scripts/procedural_audio.gd")

func _initialize() -> void:
	var audio_system := AudioSystemScript.new()
	root.add_child(audio_system)
	call_deferred("_verify_audio", audio_system)

func _verify_audio(audio_system: Node) -> void:
	await process_frame
	var ambience := audio_system.get("ambience_stream") as AudioStreamWAV
	var card := audio_system.get("card_stream") as AudioStreamWAV
	var music := audio_system.get("music_stream") as AudioStreamWAV
	if ambience == null or card == null or music == null:
		push_error("Procedural audio streams were not generated.")
		quit(1)
		return
	if ambience.data.size() < 100000 or ambience.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		push_error("Ambient drone stream is missing data or loop configuration.")
		quit(1)
		return
	if card.data.size() < 1000:
		push_error("Card sound effect stream is empty.")
		quit(1)
		return
	if music.data.size() < 300000 or music.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		push_error("Original background music stream is missing data or loop configuration.")
		quit(1)
		return
	if ambience.loop_mode != AudioStreamWAV.LOOP_FORWARD or ambience.data.size() < 300000:
		push_error("Ambient audio asset is missing data or loop configuration.")
		quit(1)
		return
	print("Pre-rendered ambience, original background music, and sound-effect assets passed.")
	quit()
