extends SceneTree

var failures := 0

func _initialize() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for frame in range(3):
		await process_frame
	_check(scene.get("status_label") as Label, "Game status:", true)
	_check(scene.get("dealer_label") as Label, "Dealer hand:", false)
	_check(scene.get("player_label") as Label, "Your hand:", false)
	_check(scene.get("chips_label") as Label, "Chips:", false)
	_check(scene.get("opponent_label") as Label, "Current opponent:", false)
	_check(scene.get("event_label") as Label, "Current table event:", false)
	_check(scene.get("survival_label") as Label, "Survival progress:", false)
	var hit := scene.get("hit_button") as Button
	var stand := scene.get("stand_button") as Button
	var double_button := scene.get("double_button") as Button
	var next_hand := scene.get("deal_button") as Button
	var ambience := scene.get("ambience_slider") as HSlider
	var effects := scene.get("effects_slider") as HSlider
	var scale := scene.get("ui_scale_slider") as HSlider
	var contrast := scene.get("high_contrast_toggle") as CheckButton
	_expect(hit.accessibility_name == "Hit", "Hit button should have a concise accessible name")
	_expect(hit.accessibility_description.contains("Draw one card"), "Hit button should explain its action")
	_expect(stand.accessibility_description.contains("dealer play"), "Stand button should explain its action")
	_expect(double_button.accessibility_description.contains("Double your current wager"), "Double button should explain its cost and action")
	_expect(next_hand.accessibility_name == "Next Hand", "Next hand should have an accessible name")
	_expect(hit.get_node_or_null(hit.focus_next) == stand, "Keyboard focus should move from Hit to Stand")
	_expect(stand.get_node_or_null(stand.focus_next) == double_button, "Keyboard focus should move from Stand to Double")
	_expect(double_button.get_node_or_null(double_button.focus_next) == next_hand, "Keyboard focus should move from Double to Next Hand")
	scene.call("_toggle_settings")
	_expect((scene.get("settings_panel") as PanelContainer).visible, "Settings should open when toggled")
	_expect(scene.get_viewport().gui_get_focus_owner() == ambience, "Opening settings should move focus to the first settings control")
	scene.call("_toggle_settings")
	_expect(not (scene.get("settings_panel") as PanelContainer).visible, "Settings should close when toggled")
	_expect(scene.get_viewport().gui_get_focus_owner() == (scene.get("settings_button") as Button), "Closing settings should return focus to the Settings button")
	_expect((scene.get("archive_button") as Button).accessibility_name.contains("of 6 entries unlocked"), "Archive button should expose a dynamic unlock count")
	_expect(ambience.accessibility_name == "Ambience volume", "Ambience slider should be named")
	_expect(effects.accessibility_name == "Sound effects volume", "Effects slider should be named")
	_expect(scale.accessibility_name == "Interface scale", "Scale slider should be named")
	_expect(contrast.accessibility_name == "High contrast", "Contrast toggle should be named")
	if failures > 0:
		push_error("Accessibility metadata test failed with %d assertion(s)." % failures)
		quit(1)
	else:
		print("AccessKit metadata and focus-order tests passed.")
		quit()
	scene.queue_free()

func _check(control: Control, expected_name: String, expect_live: bool) -> void:
	_expect(control != null, expected_name + " control should exist")
	if control == null:
		return
	_expect(control.accessibility_name.begins_with(expected_name), expected_name + " should expose a contextual accessible name")
	_expect(not control.accessibility_description.is_empty(), expected_name + " should expose a description")
	if expect_live:
		_expect(control.accessibility_live == 1, "Game status should be a polite live region")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAILED: " + message)
