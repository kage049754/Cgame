extends SceneTree

func _initialize() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for frame in range(3):
		await process_frame
	scene.set("round_active", true)
	scene.set("dealer_revealed", false)
	scene.call("_render_cards", true, false, false)
	var cards_before_tween := scene.get("cards_root") as Node3D
	if cards_before_tween.get_child(player_hand.size() - 1).position.y < 1.0:
		push_error("Newly dealt card should enter from above the table.")
		quit(1)
		return
	await process_frame
	var cards_root := scene.get("cards_root") as Node3D
	var player_hand: Array = scene.get("player_hand")
	var dealer_hand: Array = scene.get("dealer_hand")
	if cards_root == null:
		push_error("Card root was not created.")
		quit(1)
		return
	if cards_root.get_child_count() != player_hand.size() + dealer_hand.size():
		push_error("Rendered card count does not match both hands.")
		quit(1)
		return
	var face_cards := 0
	var hidden_back := false
	for card_node in cards_root.get_children():
		var labels := card_node.find_children("*", "Label3D", true, false)
		var is_back := false
		for label_node in labels:
			if (label_node as Label3D).text == "SURVIVAL 21":
				hidden_back = true
				is_back = true
		if labels.size() >= 3 and not is_back:
			face_cards += 1
	if face_cards < 3:
		push_error("Face-up cards should show corner indices and a central suit.")
		quit(1)
		return
	if not hidden_back:
		push_error("The dealer hole card should show the branded card back.")
		quit(1)
		return
	print("Detailed card face and hidden-card back tests passed.")
	quit()
