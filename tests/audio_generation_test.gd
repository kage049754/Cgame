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
	if ambience == null or card == null:
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
	print("Procedural ambient and card audio generation passed.")
	quit()
