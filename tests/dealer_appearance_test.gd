extends SceneTree

const DealerScene = preload("res://scenes/dealer_character.tscn")

func _initialize() -> void:
	var dealer: Node3D = DealerScene.instantiate()
	root.add_child(dealer)
	await process_frame
	var body := dealer.get("body_material") as StandardMaterial3D
	var eyes: Array = dealer.get("eye_materials")
	if body == null or eyes.size() != 2:
		push_error("Dealer appearance materials were not initialized.")
		quit(1)
		return
	dealer.call("set_personality", "NIGHT_DEALER")
	var night_color := body.albedo_color
	if eyes[0].emission.r < 0.5:
		push_error("Night Dealer should use red glowing eyes.")
		quit(1)
		return
	dealer.call("set_personality", "COLLECTOR")
	if body.albedo_color == night_color or eyes[0].emission.g < 0.5:
		push_error("Collector should use a distinct teal appearance.")
		quit(1)
		return
	dealer.call("set_personality", "HOUSE")
	if body.metallic < 0.5 or eyes[0].emission.r < 0.8:
		push_error("The House should use a gold metallic appearance.")
		quit(1)
		return
	print("Dealer personality appearance tests passed.")
	quit()
