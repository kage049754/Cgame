extends Node3D

const Rules = preload("res://scripts/blackjack_rules.gd")
const Opponents = preload("res://scripts/opponent_profiles.gd")
const DealerCharacterScene = preload("res://scenes/dealer_character.tscn")
const ZombieEnemyScene = preload("res://scenes/zombie_enemy.tscn")
const StreetTileScene = preload("res://assets/environment/street_4way.gltf")
const StreetLightsScene = preload("res://assets/environment/streetlights.gltf")
const RedContainerScene = preload("res://assets/environment/container_red.gltf")
const GreenContainerScene = preload("res://assets/environment/container_green.gltf")
const SurvivalItemsState = preload("res://scripts/survival_items.gd")
const SaveSystem = preload("res://scripts/survival_save.gd")
const EncounterEventsState = preload("res://scripts/encounter_events.gd")
const AudioSystemScript = preload("res://scripts/procedural_audio.gd")
const SettingsStore = preload("res://scripts/settings_store.gd")
const ControllerInput = preload("res://scripts/controller_input.gd")
const ProgressionState = preload("res://scripts/progression.gd")
const STARTING_CHIPS := 500
const BASE_BET := 25

var deck: Array[Dictionary] = []
var player_hand: Array[Dictionary] = []
var dealer_hand: Array[Dictionary] = []
var chips := STARTING_CHIPS
var current_bet := BASE_BET
var round_active := false
var round_number := 0
var status_label: Label
var player_label: Label
var dealer_label: Label
var chips_label: Label
var survival_label: Label
var opponent_label: Label
var event_label: Label
var medkit_button: Button
var marked_button: Button
var bell_button: Button
var restart_button: Button
var survival := SurvivalRun.new()
var items := SurvivalItemsState.new()
var dealer_revealed := false
var zombie_character: Node3D
var audio_system: Node
var settings_button: Button
var settings_panel: PanelContainer
var root_ui_panel: PanelContainer
var ui_scale_slider: HSlider
var high_contrast_toggle: CheckButton
var ui_layer: CanvasLayer
var ui_scale_factor := 1.0
var high_contrast_enabled := false
var archive_button: Button
var archive_dialog: AcceptDialog
var progression := ProgressionState.new()
var ambience_slider: HSlider
var effects_slider: HSlider
var house_bell_active := false
var current_event: Dictionary = {}
var hit_button: Button
var stand_button: Button
var deal_button: Button
var double_button: Button
var cards_root: Node3D

func _ready() -> void:
	_build_table()
	_build_ui()
	progression.load_profile()
	audio_system = AudioSystemScript.new()
	add_child(audio_system)
	_load_settings()
	var restored := _restore_run()
	if restored and (survival.finished or chips <= 0):
		status_label.text = "Saved run ended. Restart to play again."
		_update_ui()
		_render_cards()
	else:
		_new_round()

func _save_run() -> void:
	var state := {
		"save_version": SaveSystem.SAVE_VERSION,
		"chips": chips,
		"round_number": round_number,
		"health": survival.health,
		"wins": survival.wins,
		"losses": survival.losses,
		"pushes": survival.pushes,
		"medkit_used": survival.medkit_used,
		"finished": survival.finished,
		"ending": survival.ending,
		"marked_cards": items.marked_cards,
		"house_bells": items.house_bells
	}
	SaveSystem.save_state(state)

func _restore_run() -> bool:
	var state := SaveSystem.load_state()
	if state.is_empty():
		return false
	chips = maxi(0, int(state.get("chips", STARTING_CHIPS)))
	round_number = maxi(0, int(state.get("round_number", 0)))
	survival.health = clampi(int(state.get("health", SurvivalRun.STARTING_HEALTH)), 0, SurvivalRun.MAX_HEALTH)
	survival.wins = maxi(0, int(state.get("wins", 0)))
	survival.losses = maxi(0, int(state.get("losses", 0)))
	survival.pushes = maxi(0, int(state.get("pushes", 0)))
	survival.medkit_used = bool(state.get("medkit_used", false))
	survival.finished = bool(state.get("finished", false))
	survival.ending = str(state.get("ending", ""))
	items.marked_cards = clampi(int(state.get("marked_cards", 1)), 0, SurvivalItemsState.STARTING_MARKED_CARDS)
	items.house_bells = clampi(int(state.get("house_bells", 1)), 0, SurvivalItemsState.STARTING_HOUSE_BELLS)
	return true

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible

func _load_settings() -> void:
	var settings := SettingsStore.load_settings()
	ambience_slider.value = float(settings.get("ambience_percent", 4.0))
	effects_slider.value = float(settings.get("effects_percent", 35.0))
	ui_scale_slider.value = clampf(float(settings.get("ui_scale", 1.0)), 0.8, 1.3)
	high_contrast_toggle.button_pressed = bool(settings.get("high_contrast", false))
	_on_ambience_volume_changed(ambience_slider.value)
	_on_effects_volume_changed(effects_slider.value)
	_apply_ui_scale(ui_scale_slider.value)
	_apply_high_contrast(high_contrast_toggle.button_pressed)

func _save_settings() -> void:
	SettingsStore.save_settings({
		"ambience_percent": ambience_slider.value,
		"effects_percent": effects_slider.value,
		"ui_scale": ui_scale_slider.value,
		"high_contrast": high_contrast_toggle.button_pressed
	})

func _on_ui_scale_changed(value: float) -> void:
	_apply_ui_scale(value)
	_save_settings()

func _apply_ui_scale(value: float) -> void:
	ui_scale_factor = clampf(value, 0.8, 1.3)
	var scale_vector := Vector2.ONE * ui_scale_factor
	if root_ui_panel != null:
		root_ui_panel.scale = scale_vector
		root_ui_panel.pivot_offset = Vector2.ZERO
	if settings_panel != null:
		settings_panel.scale = scale_vector
		settings_panel.pivot_offset = settings_panel.size / 2.0

func _on_high_contrast_toggled(enabled: bool) -> void:
	_apply_high_contrast(enabled)
	_save_settings()

func _apply_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if ui_layer == null:
		return
	var accessibility_theme := Theme.new()
	var foreground := Color(1.0, 1.0, 1.0) if enabled else Color(0.88, 0.91, 0.89)
	var button_foreground := Color(1.0, 1.0, 1.0) if enabled else Color(0.9, 0.93, 0.91)
	accessibility_theme.set_color("font_color", "Label", foreground)
	accessibility_theme.set_color("font_color", "Button", button_foreground)
	accessibility_theme.set_color("font_hover_color", "Button", Color(1.0, 0.88, 0.55))
	accessibility_theme.set_color("font_pressed_color", "Button", Color(1.0, 1.0, 1.0))
	accessibility_theme.set_color("font_focus_color", "Button", Color(1.0, 0.88, 0.25))
	if root_ui_panel != null:
		root_ui_panel.theme = accessibility_theme
	if settings_panel != null:
		settings_panel.theme = accessibility_theme

func _on_ambience_volume_changed(value: float) -> void:
	if audio_system != null:
		audio_system.call("set_ambience_volume", value / 100.0)
	_save_settings()

func _on_effects_volume_changed(value: float) -> void:
	if audio_system != null:
		audio_system.call("set_effects_volume", value / 100.0)
	_save_settings()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton or not event.pressed:
		return
	var action := ControllerInput.action_for_button(event.button_index)
	match action:
		"hit":
			_on_hit()
		"stand":
			_on_stand()
		"double":
			_on_double()
		"next_hand":
			_on_next_hand()
		"marked_card":
			_on_marked_card()
		"house_bell":
			_on_house_bell()
		"restart":
			if restart_button.visible:
				_on_restart()
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_H:
			_on_hit()
		KEY_S:
			_on_stand()
		KEY_D:
			_on_double()
		KEY_N:
			_on_next_hand()
		KEY_M:
			_on_marked_card()
		KEY_B:
			_on_house_bell()
		KEY_R:
			if restart_button.visible:
				_on_restart()
		KEY_ESCAPE:
			if settings_panel.visible:
				_toggle_settings()
			elif archive_dialog.visible:
				archive_dialog.hide()
	get_viewport().set_input_as_handled()

func _build_table() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 7.2, 9.5)
	camera.rotation_degrees = Vector3(-34, 0, 0)
	camera.current = true
	add_child(camera)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-48, -25, 0)
	key_light.light_energy = 1.25
	add_child(key_light)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 3.8, 1.5)
	fill.light_color = Color(0.35, 0.52, 0.48)
	fill.light_energy = 1.8
	fill.omni_range = 12
	add_child(fill)

	var floor_mesh := MeshInstance3D.new()
	var floor := BoxMesh.new()
	floor.size = Vector3(18, 0.25, 14)
	floor_mesh.mesh = floor
	floor_mesh.position = Vector3(0, -0.75, 0)
	floor_mesh.material_override = _material(Color(0.035, 0.045, 0.05), 0.85)
	add_child(floor_mesh)
	var street_tile := StreetTileScene.instantiate()
	street_tile.position = Vector3(0, -0.75, 0)
	street_tile.scale = Vector3(2.0, 1.0, 1.7)
	add_child(street_tile)

	var pedestal_mesh := MeshInstance3D.new()
	var pedestal := CylinderMesh.new()
	pedestal.top_radius = 1.5
	pedestal.bottom_radius = 1.8
	pedestal.height = 0.3
	pedestal_mesh.mesh = pedestal
	pedestal_mesh.position.y = -0.4
	pedestal_mesh.material_override = _material(Color(0.055, 0.065, 0.07), 0.8)
	add_child(pedestal_mesh)

	var red_container := RedContainerScene.instantiate()
	red_container.position = Vector3(7.0, -0.55, 1.4)
	red_container.scale = Vector3.ONE * 0.68
	add_child(red_container)

	var green_container := GreenContainerScene.instantiate()
	green_container.position = Vector3(-7.0, -0.55, 1.4)
	green_container.scale = Vector3.ONE * 0.68
	green_container.rotation_degrees.y = 180
	add_child(green_container)

	for side in [-1.0, 1.0]:
		var streetlight := StreetLightsScene.instantiate()
		streetlight.position = Vector3(side * 7.0, -0.55, -5.5)
		streetlight.scale = Vector3.ONE * 0.9
		add_child(streetlight)
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(side * 7.0, 4.5, -5.5)
		lamp.light_color = Color(1.0, 0.55, 0.28)
		lamp.light_energy = 1.6
		lamp.omni_range = 10.0
		add_child(lamp)

	var table_mesh := MeshInstance3D.new()
	var table := CylinderMesh.new()
	table.top_radius = 4.5
	table.bottom_radius = 4.5
	table.height = 0.5
	table.radial_segments = 64
	table_mesh.mesh = table
	table_mesh.position = Vector3(0, 0, 0)
	table_mesh.material_override = _material(Color(0.025, 0.22, 0.16), 0.92)
	add_child(table_mesh)

	var rim := MeshInstance3D.new()
	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = 4.35
	rim_mesh.outer_radius = 4.52
	rim.mesh = rim_mesh
	rim.position.y = 0.28
	rim.material_override = _material(Color(0.38, 0.22, 0.11), 0.35)
	add_child(rim)

	cards_root = Node3D.new()
	cards_root.name = "Cards"
	add_child(cards_root)
	var dealer_character := DealerCharacterScene.instantiate()
	dealer_character.position = Vector3(0, -0.55, -4.05)
	add_child(dealer_character)
	zombie_character = ZombieEnemyScene.instantiate() as Node3D
	zombie_character.position = Vector3(-4.05, -0.55, -1.65)
	zombie_character.scale = Vector3.ONE * 0.82
	add_child(zombie_character)

func _material(color: Color, roughness: float = 0.65) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	var panel := PanelContainer.new()
	root_ui_panel = panel
	panel.position = Vector2(22, 18)
	panel.size = Vector2(460, 470)
	ui_layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	panel.add_child(column)

	var title := Label.new()
	title.text = "S U R V I V A L   2 1"
	title.add_theme_font_size_override("font_size", 25)
	column.add_child(title)
	status_label = Label.new()
	status_label.text = "The table is waiting."
	column.add_child(status_label)
	dealer_label = Label.new()
	column.add_child(dealer_label)
	player_label = Label.new()
	column.add_child(player_label)
	chips_label = Label.new()
	column.add_child(chips_label)
	opponent_label = Label.new()
	column.add_child(opponent_label)
	event_label = Label.new()
	column.add_child(event_label)
	survival_label = Label.new()
	column.add_child(survival_label)

	var actions := HBoxContainer.new()
	column.add_child(actions)
	hit_button = _make_button("HIT", _on_hit)
	actions.add_child(hit_button)
	stand_button = _make_button("STAND", _on_stand)
	actions.add_child(stand_button)
	double_button = _make_button("DOUBLE", _on_double)
	actions.add_child(double_button)
	deal_button = _make_button("NEXT HAND", _on_next_hand)
	actions.add_child(deal_button)
	var item_actions := HBoxContainer.new()
	column.add_child(item_actions)
	medkit_button = _make_button("MEDKIT (75)", _on_medkit)
	item_actions.add_child(medkit_button)
	marked_button = _make_button("MARKED (1)", _on_marked_card)
	item_actions.add_child(marked_button)
	bell_button = _make_button("BELL (1)", _on_house_bell)
	item_actions.add_child(bell_button)
	settings_button = _make_button("SETTINGS", _toggle_settings)
	column.add_child(settings_button)
	archive_button = _make_button("ARCHIVE (0/6)", _show_archive)
	column.add_child(archive_button)
	archive_dialog = AcceptDialog.new()
	archive_dialog.title = "SURVIVAL ARCHIVE"
	archive_dialog.dialog_text = ""
	archive_dialog.min_size = Vector2i(520, 420)
	ui_layer.add_child(archive_dialog)
	restart_button = _make_button("RESTART RUN", _on_restart)
	restart_button.custom_minimum_size = Vector2(150, 42)
	restart_button.visible = false
	column.add_child(restart_button)

	settings_panel = PanelContainer.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -150
	settings_panel.offset_right = 150
	settings_panel.offset_top = -205
	settings_panel.offset_bottom = 205
	settings_panel.visible = false
	ui_layer.add_child(settings_panel)
	var settings_column := VBoxContainer.new()
	settings_panel.add_child(settings_column)
	var settings_title := Label.new()
	settings_title.text = "AUDIO SETTINGS"
	settings_column.add_child(settings_title)
	var ambience_label := Label.new()
	ambience_label.text = "AMBIENCE VOLUME"
	settings_column.add_child(ambience_label)
	ambience_slider = HSlider.new()
	ambience_slider.min_value = 0
	ambience_slider.max_value = 100
	ambience_slider.step = 1
	ambience_slider.custom_minimum_size = Vector2(260, 32)
	ambience_slider.value_changed.connect(_on_ambience_volume_changed)
	settings_column.add_child(ambience_slider)
	var effects_label := Label.new()
	effects_label.text = "SOUND EFFECT VOLUME"
	settings_column.add_child(effects_label)
	effects_slider = HSlider.new()
	effects_slider.min_value = 0
	effects_slider.max_value = 100
	effects_slider.step = 1
	effects_slider.custom_minimum_size = Vector2(260, 32)
	effects_slider.value_changed.connect(_on_effects_volume_changed)
	settings_column.add_child(effects_slider)
	var scale_label := Label.new()
	scale_label.text = "UI SCALE"
	settings_column.add_child(scale_label)
	ui_scale_slider = HSlider.new()
	ui_scale_slider.min_value = 0.8
	ui_scale_slider.max_value = 1.3
	ui_scale_slider.step = 0.05
	ui_scale_slider.custom_minimum_size = Vector2(260, 32)
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	settings_column.add_child(ui_scale_slider)
	high_contrast_toggle = CheckButton.new()
	high_contrast_toggle.text = "HIGH CONTRAST"
	high_contrast_toggle.toggled.connect(_on_high_contrast_toggled)
	settings_column.add_child(high_contrast_toggle)
	var close_settings := _make_button("CLOSE", _toggle_settings)
	settings_column.add_child(close_settings)

	var hint := Label.new()
	hint.text = "H Hit | S Stand | D Double | N Next | M Mark | B Bell  •  Pad: A/B/X/Y, LB/RB, Start"
	hint.add_theme_color_override("font_color", Color(0.72, 0.78, 0.75))
	column.add_child(hint)
	hit_button.grab_focus()

func _make_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(86, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = caption
	button.pressed.connect(callback)
	return button

func _create_deck() -> void:
	deck.clear()
	for suit in range(4):
		for rank in range(1, 14):
			deck.append({"rank": rank, "suit": suit})
	deck.shuffle()

func _draw_card(hand: Array[Dictionary]) -> void:
	if deck.is_empty():
		_create_deck()
	hand.append(deck.pop_back())
	if audio_system != null:
		audio_system.call("play_card")

func _new_round() -> void:
	if survival.finished:
		status_label.text = "The run has ended. Restart to enter the table again."
		_update_ui()
		return
	if chips <= 0:
		status_label.text = "You're out of chips. Restart the game to try again."
		_update_ui()
		return
	round_number += 1
	dealer_revealed = false
	house_bell_active = false
	current_event = EncounterEventsState.event_for_round(round_number)
	if zombie_character != null:
		zombie_character.call("play_animation", "Idle_Attack" if bool(current_event.get("force_soft_17", false)) else "Idle")
	current_bet = mini(BASE_BET, chips)
	chips -= current_bet
	player_hand.clear()
	dealer_hand.clear()
	_create_deck()
	_draw_card(player_hand)
	_draw_card(dealer_hand)
	_draw_card(player_hand)
	_draw_card(dealer_hand)
	round_active = true
	status_label.text = "Round %d — %s." % [round_number, current_event.get("name", "QUIET TABLE")]
	if Rules.is_blackjack(player_hand) or Rules.is_blackjack(dealer_hand):
		_finish_round()
	_update_ui()
	_render_cards()

func _on_restart() -> void:
	SaveSystem.delete_state()
	survival.reset()
	items.reset()
	chips = STARTING_CHIPS
	current_bet = BASE_BET
	round_number = 0
	round_active = false
	dealer_revealed = false
	house_bell_active = false
	status_label.text = "A new run begins."
	_new_round()

func _on_hit() -> void:
	if not round_active:
		return
	_draw_card(player_hand)
	if Rules.is_bust(player_hand):
		_finish_round()
	else:
		status_label.text = "You drew %s." % Rules.card_label(player_hand.back())
	_update_ui()
	_render_cards()

func _on_stand() -> void:
	if not round_active:
		return
	while Opponents.should_dealer_hit(dealer_hand, survival.wins, house_bell_active, bool(current_event.get("force_soft_17", false))):
		_draw_card(dealer_hand)
	_finish_round()
	_update_ui()
	_render_cards()

func _on_double() -> void:
	if not round_active or player_hand.size() != 2 or chips < current_bet:
		return
	chips -= current_bet
	current_bet *= 2
	_draw_card(player_hand)
	if not Rules.is_bust(player_hand):
		while Opponents.should_dealer_hit(dealer_hand, survival.wins, house_bell_active, bool(current_event.get("force_soft_17", false))):
			_draw_card(dealer_hand)
	_finish_round()
	_update_ui()
	_render_cards()

func _on_next_hand() -> void:
	if not round_active and not survival.finished:
		_new_round()

func _on_medkit() -> void:
	if not round_active and survival.use_medkit(chips):
		chips -= 75
		status_label.text = "Medkit used. One heart restored."
		if audio_system != null:
			audio_system.call("play_item")
		_save_run()
		_update_ui()

func _on_marked_card() -> void:
	if items.use_marked_card(round_active):
		progression.record_item_use("marked_card")
		dealer_revealed = true
		status_label.text = "The marked card reveals the dealer's hidden card."
		if audio_system != null:
			audio_system.call("play_item")
		_update_ui()
		_render_cards()

func _on_house_bell() -> void:
	if items.use_house_bell(round_active):
		progression.record_item_use("house_bell")
		house_bell_active = true
		status_label.text = "The House Bell is armed. The dealer will stand this hand."
		if audio_system != null:
			audio_system.call("play_item")
		_update_ui()

func _finish_round() -> void:
	if not round_active:
		return
	round_active = false
	var opponent_name := str(Opponents.profile_for_wins(survival.wins).get("name", "UNKNOWN"))
	var result := Rules.outcome(player_hand, dealer_hand)
	survival.resolve_hand(result)
	if zombie_character != null:
		zombie_character.call("play_outcome", result, survival.ending)
	if audio_system != null:
		if result == "win":
			audio_system.call("play_win")
		elif result == "lose":
			audio_system.call("play_loss")
		else:
			audio_system.call("play_push")
	if Rules.is_blackjack(player_hand) and result == "win":
		chips += int(round(float(current_bet) * 2.5)) + EncounterEventsState.win_bonus_for(current_event, Rules.is_bust(dealer_hand))
		status_label.text = "BLACKJACK! You win 3:2."
	elif result == "win":
		chips += current_bet * 2 + EncounterEventsState.win_bonus_for(current_event, Rules.is_bust(dealer_hand))
		status_label.text = "You survived this hand. You win."
	elif result == "push":
		var bonus := int(current_event.get("push_bonus", 0))
		chips += current_bet + bonus
		status_label.text = "Push. Your bet is returned%s." % (" + %d bonus chips" % bonus if bonus > 0 else "")
	else:
		chips = maxi(0, chips - EncounterEventsState.loss_tax_for(current_event, Rules.is_bust(player_hand)))
		status_label.text = "You lost this hand."
	if survival.ending == "victory":
		status_label.text = "THE HOUSE IS BROKEN. YOU SURVIVED."
	elif survival.ending == "defeat":
		status_label.text = "YOUR LAST HEART FADES. THE HOUSE WINS."
	progression.record_hand(result, opponent_name, survival.ending)
	progression.save_profile()
	_update_ui()
	_save_run()

func _show_archive() -> void:
	archive_dialog.dialog_text = progression.archive_text()
	archive_dialog.popup_centered()

func _render_cards() -> void:
	for child in cards_root.get_children():
		child.queue_free()
	_add_hand_visuals(player_hand, Vector3(-1.65, 0.34, 1.45), false)
	_add_hand_visuals(dealer_hand, Vector3(-1.65, 0.34, -1.25), round_active and not dealer_revealed)

func _add_hand_visuals(hand: Array[Dictionary], origin: Vector3, hide_second: bool) -> void:
	for index in range(hand.size()):
		var card_node := Node3D.new()
		card_node.position = origin + Vector3(index * 0.85, index * 0.012, 0)
		cards_root.add_child(card_node)
		var card_mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.72, 0.055, 1.02)
		card_mesh.mesh = box
		card_mesh.material_override = _material(Color(0.08, 0.16, 0.2) if hide_second and index == 1 else Color(0.92, 0.91, 0.84), 0.35)
		card_node.add_child(card_mesh)
		if not (hide_second and index == 1):
			var face := Label3D.new()
			face.text = Rules.card_label(hand[index])
			face.font_size = 64
			face.pixel_size = 0.0028
			face.position = Vector3(-0.25, 0.04, -0.32)
			face.rotation_degrees.x = -90
			face.modulate = Color(0.65, 0.08, 0.08) if int(hand[index].suit) in [1, 2] else Color(0.05, 0.06, 0.07)
			card_node.add_child(face)

func _update_ui() -> void:
	var dealer_value := "?" if round_active and not dealer_revealed else str(Rules.hand_value(dealer_hand))
	dealer_label.text = "DEALER  %s  |  %d cards" % [dealer_value, dealer_hand.size()]
	player_label.text = "YOU  %d  |  %d cards  |  Bet: %d" % [Rules.hand_value(player_hand), player_hand.size(), current_bet]
	chips_label.text = "CHIPS  %d" % chips
	var opponent_profile := Opponents.profile_for_wins(survival.wins)
	opponent_label.text = "OPPONENT  %s — %s" % [opponent_profile.get("name", "UNKNOWN"), opponent_profile.get("tell", "")]
	event_label.text = "EVENT  %s — %s" % [current_event.get("name", "QUIET TABLE"), current_event.get("description", "")]
	survival_label.text = "HEARTS  %s   |   WINS  %d / %d   |   LOSSES  %d" % ["♥".repeat(survival.health) + "♡".repeat(SurvivalRun.MAX_HEALTH - survival.health), survival.wins, SurvivalRun.REQUIRED_WINS, survival.losses]
	hit_button.disabled = not round_active
	stand_button.disabled = not round_active
	double_button.disabled = not round_active or player_hand.size() != 2 or chips < current_bet
	deal_button.disabled = round_active or chips <= 0 or survival.finished
	medkit_button.disabled = round_active or survival.finished or survival.medkit_used or survival.health >= SurvivalRun.MAX_HEALTH or chips < 75
	marked_button.text = "MARKED (%d)" % items.marked_cards
	bell_button.text = "BELL ACTIVE" if house_bell_active else "BELL (%d)" % items.house_bells
	marked_button.disabled = not round_active or items.marked_cards <= 0 or dealer_revealed
	bell_button.disabled = not round_active or items.house_bells <= 0 or house_bell_active
	restart_button.visible = not round_active and (survival.finished or chips <= 0)
	archive_button.text = "ARCHIVE (%d/6)" % progression.unlocked_count()
