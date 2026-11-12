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
const VisualEffects = preload("res://scripts/visual_effects.gd")
const AccessibilityLayout = preload("res://scripts/accessibility_layout.gd")
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
var dealer_character: Node3D
var main_camera: Camera3D
var camera_rest_position := Vector3.ZERO
var table_fill_light: OmniLight3D
var outcome_light_tween: Tween
var camera_shake_tween: Tween
var audio_system: Node
var settings_button: Button
var settings_panel: PanelContainer
var root_ui_panel: PanelContainer
var ui_scale_slider: HSlider
var high_contrast_toggle: CheckButton
var starting_opponent_selector: OptionButton
var starting_opponent_label: Label
var selected_starting_tier := 0
var settings_loading := false
var run_starting_tier := 0
var ui_layer: CanvasLayer
var ui_scale_factor := 1.0
var high_contrast_enabled := false
var archive_button: Button
var archive_dialog: AcceptDialog
var progression := ProgressionState.new()
var ambience_slider: HSlider
var music_slider: HSlider
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
	_update_ui()
	await RenderingServer.frame_post_draw
	audio_system = AudioSystemScript.new()
	add_child(audio_system)
	_load_settings()
	run_starting_tier = selected_starting_tier
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
		"house_bells": items.house_bells,
		"starting_opponent_tier": run_starting_tier
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
	run_starting_tier = Opponents.highest_unlocked_tier(int(state.get("starting_opponent_tier", selected_starting_tier)), progression.unlocked)
	return true

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	if settings_panel.visible:
		starting_opponent_selector.grab_focus()
	else:
		settings_button.grab_focus()

func _load_settings() -> void:
	settings_loading = true
	var settings := SettingsStore.load_settings()
	ambience_slider.value = float(settings.get("ambience_percent", 4.0))
	music_slider.value = float(settings.get("music_percent", 20.0))
	effects_slider.value = float(settings.get("effects_percent", 35.0))
	ui_scale_slider.value = clampf(float(settings.get("ui_scale", 1.0)), 0.8, 1.3)
	high_contrast_toggle.button_pressed = bool(settings.get("high_contrast", false))
	selected_starting_tier = Opponents.highest_unlocked_tier(int(settings.get("starting_opponent_tier", 0)), progression.unlocked)
	starting_opponent_selector.select(selected_starting_tier)
	_refresh_opponent_choices()
	_on_ambience_volume_changed(ambience_slider.value)
	_on_music_volume_changed(music_slider.value)
	_on_effects_volume_changed(effects_slider.value)
	_apply_ui_scale(ui_scale_slider.value)
	_apply_high_contrast(high_contrast_toggle.button_pressed)
	settings_loading = false

func _save_settings() -> void:
	if settings_loading:
		return
	SettingsStore.save_settings({
		"ambience_percent": ambience_slider.value,
		"music_percent": music_slider.value,
		"effects_percent": effects_slider.value,
		"ui_scale": ui_scale_slider.value,
		"high_contrast": high_contrast_toggle.button_pressed,
		"starting_opponent_tier": selected_starting_tier
	})

func _refresh_opponent_choices() -> void:
	if starting_opponent_selector == null:
		return
	starting_opponent_selector.set_item_disabled(1, not progression.unlocked.has("COLLECTOR"))
	starting_opponent_selector.set_item_disabled(2, not progression.unlocked.has("HOUSE"))
	var resolved := Opponents.highest_unlocked_tier(selected_starting_tier, progression.unlocked)
	if resolved != selected_starting_tier:
		selected_starting_tier = resolved
		starting_opponent_selector.select(selected_starting_tier)

func _on_starting_opponent_selected(index: int) -> void:
	selected_starting_tier = Opponents.highest_unlocked_tier(index, progression.unlocked)
	starting_opponent_selector.select(selected_starting_tier)
	_save_settings()
	var profile := Opponents.profile_for_tier(selected_starting_tier)
	status_label.text = "%s will start your next run." % profile.get("name", "THE NIGHT DEALER")
	_update_ui()

func _current_opponent_profile() -> Dictionary:
	return Opponents.profile_for_wins(survival.wins, run_starting_tier)

func _refresh_dealer_appearance() -> void:
	if dealer_character == null:
		return
	var profile := _current_opponent_profile()
	dealer_character.call("set_personality", str(profile.get("id", "NIGHT_DEALER")))

func _on_ui_scale_changed(value: float) -> void:
	_apply_ui_scale(value)
	_save_settings()

func _apply_ui_scale(value: float) -> void:
	ui_scale_factor = clampf(value, 0.8, 1.3)
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	if root_ui_panel == null or settings_panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var fit_scale := AccessibilityLayout.fit_scale(viewport_size, Vector2(460, 470), 24.0)
	var final_scale := fit_scale * ui_scale_factor
	var scale_vector := Vector2.ONE * final_scale
	root_ui_panel.position = Vector2(12, 12)
	root_ui_panel.scale = scale_vector
	root_ui_panel.pivot_offset = Vector2.ZERO
	settings_panel.scale = scale_vector
	settings_panel.pivot_offset = settings_panel.size / 2.0
	if archive_dialog != null:
		archive_dialog.min_size = Vector2i(
			mini(520, maxi(280, int(viewport_size.x * 0.9))),
			mini(420, maxi(240, int(viewport_size.y * 0.75)))
		)

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

func _play_outcome_effect(result: String) -> void:
	if table_fill_light == null:
		return
	var flash_color := VisualEffects.flash_color(result)
	if outcome_light_tween != null and outcome_light_tween.is_running():
		outcome_light_tween.kill()
	table_fill_light.light_color = flash_color
	table_fill_light.light_energy = 2.8
	outcome_light_tween = create_tween()
	outcome_light_tween.set_parallel(true)
	outcome_light_tween.tween_property(table_fill_light, "light_color", Color(0.35, 0.52, 0.48), 0.65)
	outcome_light_tween.tween_property(table_fill_light, "light_energy", 1.8, 0.65)
	var shake_strength := VisualEffects.camera_shake_strength(result)
	if shake_strength > 0.0 and main_camera != null:
		if camera_shake_tween != null and camera_shake_tween.is_running():
			camera_shake_tween.kill()
		main_camera.position = camera_rest_position
		camera_shake_tween = create_tween()
		camera_shake_tween.tween_property(main_camera, "position", camera_rest_position + Vector3(shake_strength, shake_strength * 0.29, 0), 0.045)
		camera_shake_tween.tween_property(main_camera, "position", camera_rest_position + Vector3(-shake_strength * 0.83, -shake_strength * 0.16, 0), 0.055)
		camera_shake_tween.tween_property(main_camera, "position", camera_rest_position, 0.08)

func _on_music_volume_changed(value: float) -> void:
	if audio_system != null:
		audio_system.call("set_music_volume", value / 100.0)
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
				archive_button.grab_focus()
	get_viewport().set_input_as_handled()

func _build_table() -> void:
	main_camera = Camera3D.new()
	main_camera.position = Vector3(0, 7.2, 9.5)
	main_camera.rotation_degrees = Vector3(-34, 0, 0)
	main_camera.current = true
	camera_rest_position = main_camera.position
	add_child(main_camera)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-48, -25, 0)
	key_light.light_energy = 1.25
	add_child(key_light)

	table_fill_light = OmniLight3D.new()
	table_fill_light.position = Vector3(0, 3.8, 1.5)
	table_fill_light.light_color = Color(0.35, 0.52, 0.48)
	table_fill_light.light_energy = 1.8
	table_fill_light.omni_range = 12
	add_child(table_fill_light)

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
	dealer_character = DealerCharacterScene.instantiate()
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
	title.accessibility_name = "Survival 21"
	title.accessibility_description = "Horror survival blackjack game. Play hands to escape the table."
	column.add_child(title)
	status_label = Label.new()
	status_label.text = "The table is waiting."
	status_label.accessibility_name = "Game status"
	status_label.accessibility_description = "Announces the current round, game events, and results."
	status_label.accessibility_live = 1
	column.add_child(status_label)
	dealer_label = Label.new()
	dealer_label.accessibility_name = "Dealer hand"
	dealer_label.accessibility_description = "Dealer card count and total. A question mark means the hole card is hidden."
	column.add_child(dealer_label)
	player_label = Label.new()
	player_label.accessibility_name = "Your hand"
	player_label.accessibility_description = "Your current card total, card count, and wager."
	column.add_child(player_label)
	chips_label = Label.new()
	chips_label.accessibility_name = "Chips"
	chips_label.accessibility_description = "Your available virtual chips. Chips have no real-money value."
	column.add_child(chips_label)
	opponent_label = Label.new()
	opponent_label.accessibility_name = "Current opponent"
	opponent_label.accessibility_description = "The dealer personality and its blackjack strategy."
	column.add_child(opponent_label)
	event_label = Label.new()
	event_label.accessibility_name = "Current table event"
	event_label.accessibility_description = "The special rule active for this blackjack hand."
	column.add_child(event_label)
	survival_label = Label.new()
	survival_label.accessibility_name = "Survival progress"
	survival_label.accessibility_description = "Remaining hearts, wins needed to escape, and losses."
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
	archive_dialog.confirmed.connect(archive_button.grab_focus)
	restart_button = _make_button("RESTART RUN", _on_restart)
	restart_button.custom_minimum_size = Vector2(150, 42)
	restart_button.visible = false
	column.add_child(restart_button)

	settings_panel = PanelContainer.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -150
	settings_panel.offset_right = 150
	settings_panel.offset_top = -285
	settings_panel.offset_bottom = 285
	settings_panel.visible = false
	ui_layer.add_child(settings_panel)
	var settings_column := VBoxContainer.new()
	settings_panel.add_child(settings_column)
	var settings_title := Label.new()
	settings_title.name = "SettingsTitle"
	settings_title.text = "AUDIO SETTINGS"
	settings_title.accessibility_name = "Settings"
	settings_title.accessibility_description = "Audio, display scale, and contrast options."
	settings_column.add_child(settings_title)
	starting_opponent_label = Label.new()
	starting_opponent_label.name = "StartingOpponentLabel"
	starting_opponent_label.text = "STARTING HOUSE (NEXT RUN)"
	starting_opponent_label.accessibility_name = "Starting house"
	starting_opponent_label.accessibility_description = "Choose which unlocked dealer starts the next survival run."
	settings_column.add_child(starting_opponent_label)
	starting_opponent_selector = OptionButton.new()
	starting_opponent_selector.name = "StartingOpponentSelector"
	starting_opponent_selector.custom_minimum_size = Vector2(260, 36)
	starting_opponent_selector.add_item("Night Dealer", 0)
	starting_opponent_selector.add_item("Collector", 1)
	starting_opponent_selector.add_item("The House", 2)
	starting_opponent_selector.accessibility_name = "Starting opponent"
	starting_opponent_selector.accessibility_description = "Choose an unlocked opponent for your next run. Collector and The House unlock after defeating them."
	starting_opponent_selector.item_selected.connect(_on_starting_opponent_selected)
	settings_column.add_child(starting_opponent_selector)
	var ambience_label := Label.new()
	ambience_label.name = "AmbienceLabel"
	ambience_label.text = "AMBIENCE VOLUME"
	ambience_label.accessibility_name = "Ambience volume"
	ambience_label.accessibility_description = "Label for the background ambience volume slider."
	settings_column.add_child(ambience_label)
	ambience_slider = HSlider.new()
	ambience_slider.min_value = 0
	ambience_slider.max_value = 100
	ambience_slider.step = 1
	ambience_slider.custom_minimum_size = Vector2(260, 32)
	ambience_slider.accessibility_name = "Ambience volume"
	ambience_slider.accessibility_description = "Adjust background horror ambience from zero to one hundred percent."
	ambience_slider.value_changed.connect(_on_ambience_volume_changed)
	settings_column.add_child(ambience_slider)
	var music_label := Label.new()
	music_label.name = "MusicLabel"
	music_label.text = "BACKGROUND MUSIC"
	music_label.accessibility_name = "Background music volume"
	music_label.accessibility_description = "Label for the background music volume slider."
	settings_column.add_child(music_label)
	music_slider = HSlider.new()
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	music_slider.custom_minimum_size = Vector2(260, 32)
	music_slider.accessibility_name = "Background music volume"
	music_slider.accessibility_description = "Adjust the original looping horror music from zero to one hundred percent."
	music_slider.value_changed.connect(_on_music_volume_changed)
	settings_column.add_child(music_slider)
	var effects_label := Label.new()
	effects_label.name = "EffectsLabel"
	effects_label.text = "SOUND EFFECT VOLUME"
	effects_label.accessibility_name = "Sound effects volume"
	effects_label.accessibility_description = "Label for the sound effects volume slider."
	settings_column.add_child(effects_label)
	effects_slider = HSlider.new()
	effects_slider.min_value = 0
	effects_slider.max_value = 100
	effects_slider.step = 1
	effects_slider.custom_minimum_size = Vector2(260, 32)
	effects_slider.accessibility_name = "Sound effects volume"
	effects_slider.accessibility_description = "Adjust card, result, and item sound effects from zero to one hundred percent."
	effects_slider.value_changed.connect(_on_effects_volume_changed)
	settings_column.add_child(effects_slider)
	var scale_label := Label.new()
	scale_label.name = "ScaleLabel"
	scale_label.text = "UI SCALE"
	scale_label.accessibility_name = "Interface scale"
	scale_label.accessibility_description = "Label for the interface scale slider."
	settings_column.add_child(scale_label)
	ui_scale_slider = HSlider.new()
	ui_scale_slider.min_value = 0.8
	ui_scale_slider.max_value = 1.3
	ui_scale_slider.step = 0.05
	ui_scale_slider.custom_minimum_size = Vector2(260, 32)
	ui_scale_slider.accessibility_name = "Interface scale"
	ui_scale_slider.accessibility_description = "Resize the game interface from eighty to one hundred and thirty percent."
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	settings_column.add_child(ui_scale_slider)
	high_contrast_toggle = CheckButton.new()
	high_contrast_toggle.text = "HIGH CONTRAST"
	high_contrast_toggle.accessibility_name = "High contrast"
	high_contrast_toggle.accessibility_description = "Increase text contrast for improved readability."
	high_contrast_toggle.toggled.connect(_on_high_contrast_toggled)
	settings_column.add_child(high_contrast_toggle)
	var close_settings := _make_button("CLOSE", _toggle_settings)
	settings_column.add_child(close_settings)

	var hint := Label.new()
	hint.text = "H Hit | S Stand | D Double | N Next | M Mark | B Bell  •  Pad: A/B/X/Y, LB/RB, Start"
	hint.add_theme_color_override("font_color", Color(0.72, 0.78, 0.75))
	column.add_child(hint)
	_link_focus_order([hit_button, stand_button, double_button, deal_button, medkit_button, marked_button, bell_button, settings_button, archive_button, restart_button])
	_link_accessibility_flow([
		title, status_label, dealer_label, player_label, chips_label, opponent_label,
		event_label, survival_label, hit_button, stand_button, double_button, deal_button,
		medkit_button, marked_button, bell_button, settings_button, archive_button, restart_button
	])
	_link_focus_order([starting_opponent_selector, ambience_slider, music_slider, effects_slider, ui_scale_slider, high_contrast_toggle, close_settings])
	_link_accessibility_flow([
		settings_title, starting_opponent_label, starting_opponent_selector,
		ambience_label, ambience_slider, music_label, music_slider, effects_label, effects_slider,
		scale_label, ui_scale_slider, high_contrast_toggle, close_settings
	])
	hit_button.grab_focus()
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _make_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(86, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = caption
	button.accessibility_name = caption.capitalize()
	button.accessibility_description = _button_accessibility_description(caption)
	button.pressed.connect(callback)
	return button

func _button_accessibility_description(caption: String) -> String:
	if caption.begins_with("MARKED"):
		return "Reveal the dealer’s hidden card for this hand. One use per run."
	if caption.begins_with("BELL"):
		return "Prevent the dealer from drawing for this hand. One use per run."
	match caption:
		"HIT":
			return "Draw one card. Your hand ends automatically if it goes over twenty one."
		"STAND":
			return "Keep your current total and let the dealer play."
		"DOUBLE":
			return "Double your current wager, draw one final card, and end your turn."
		"NEXT HAND":
			return "Start the next blackjack hand."
		"MEDKIT (75)":
			return "Spend seventy five virtual chips to restore one heart. Usable once per run."
		"SETTINGS":
			return "Open audio volume, interface scale, and high contrast options."
		"ARCHIVE (0/6)":
			return "View unlocked survival lore and lifetime achievements."
		"RESTART RUN":
			return "Discard the current run and start a new run with five hundred chips."
		"CLOSE":
			return "Close settings and return focus to the game."
		_:
			return "Use the current tactical item. " + caption.capitalize()

func _link_focus_order(controls: Array[Control]) -> void:
	for index in range(controls.size()):
		var current := controls[index]
		var next := controls[(index + 1) % controls.size()]
		current.focus_next = current.get_path_to(next)

func _link_accessibility_flow(controls: Array[Control]) -> void:
	for index in range(controls.size() - 1):
		var current := controls[index]
		var next := controls[index + 1]
		current.accessibility_flow_to_nodes = [current.get_path_to(next)]

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
	_render_cards(false, false, true)

func _on_restart() -> void:
	SaveSystem.delete_state()
	survival.reset()
	items.reset()
	run_starting_tier = selected_starting_tier
	_refresh_dealer_appearance()
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
	_render_cards(true, false, false)

func _on_stand() -> void:
	if not round_active:
		return
	while Opponents.should_dealer_hit(dealer_hand, survival.wins, house_bell_active, bool(current_event.get("force_soft_17", false)), run_starting_tier):
		_draw_card(dealer_hand)
	_finish_round()
	_update_ui()
	_render_cards(false, true, false)

func _on_double() -> void:
	if not round_active or player_hand.size() != 2 or chips < current_bet:
		return
	chips -= current_bet
	current_bet *= 2
	_draw_card(player_hand)
	if not Rules.is_bust(player_hand):
		while Opponents.should_dealer_hit(dealer_hand, survival.wins, house_bell_active, bool(current_event.get("force_soft_17", false)), run_starting_tier):
			_draw_card(dealer_hand)
	_finish_round()
	_update_ui()
	_render_cards(true, true, false)

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
		_render_cards(false, true, false)

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
	var opponent_name := str(_current_opponent_profile().get("name", "UNKNOWN"))
	var result := Rules.outcome(player_hand, dealer_hand)
	survival.resolve_hand(result)
	_refresh_dealer_appearance()
	_play_outcome_effect(result)
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
	_refresh_opponent_choices()
	_update_ui()
	_save_run()

func _show_archive() -> void:
	archive_dialog.dialog_text = progression.archive_text()
	archive_dialog.popup_centered()
	var archive_labels := archive_dialog.find_children("*", "Label", true, false)
	var archive_buttons := archive_dialog.find_children("*", "Button", true, false)
	for node in archive_labels:
		var archive_label := node as Label
		archive_label.accessibility_name = "Survival archive entries"
		archive_label.accessibility_description = archive_dialog.dialog_text
	for node in archive_buttons:
		var dialog_button := node as Button
		dialog_button.accessibility_name = "Close survival archive"
		dialog_button.accessibility_description = "Close the archive and return to the Archive button."
		dialog_button.grab_focus()
	if not archive_labels.is_empty() and not archive_buttons.is_empty():
		var archive_label := archive_labels[0] as Label
		archive_label.accessibility_flow_to_nodes = [archive_label.get_path_to(archive_buttons[0])]

func _render_cards(animate_player_last: bool = false, animate_dealer_last: bool = false, animate_all: bool = false) -> void:
	for child in cards_root.get_children():
		child.free()
	_add_hand_visuals(player_hand, Vector3(-1.65, 0.34, 1.45), false, animate_player_last, animate_all)
	_add_hand_visuals(dealer_hand, Vector3(-1.65, 0.34, -1.25), round_active and not dealer_revealed, animate_dealer_last, animate_all)

func _add_hand_visuals(hand: Array[Dictionary], origin: Vector3, hide_second: bool, animate_last: bool = false, animate_all: bool = false) -> void:
	for index in range(hand.size()):
		var is_hidden := hide_second and index == 1
		var card_node := Node3D.new()
		var target_position := origin + Vector3(index * 0.85, index * 0.012, 0)
		var should_animate := animate_all or (animate_last and index == hand.size() - 1)
		card_node.position = target_position + (Vector3(0, 1.35, 0) if should_animate else Vector3.ZERO)
		card_node.rotation_degrees = Vector3(-14, 0, 0) if should_animate else Vector3.ZERO
		cards_root.add_child(card_node)
		if should_animate:
			var entry_tween := create_tween()
			entry_tween.set_parallel(true)
			entry_tween.tween_property(card_node, "position", target_position, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(index * 0.045)
			entry_tween.tween_property(card_node, "rotation_degrees", Vector3.ZERO, 0.28)
		var card_mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.72, 0.055, 1.02)
		card_mesh.mesh = box
		card_mesh.material_override = _material(Color(0.035, 0.075, 0.12) if is_hidden else Color(0.94, 0.93, 0.87), 0.3)
		card_node.add_child(card_mesh)
		_add_card_border(card_node, Color(0.76, 0.59, 0.28) if is_hidden else Color(0.42, 0.34, 0.23))
		if is_hidden:
			_add_card_text(card_node, "✦", Vector3(0, 0.041, 0), 112, Color(0.88, 0.68, 0.3))
			_add_card_text(card_node, "SURVIVAL 21", Vector3(0, 0.041, -0.34), 18, Color(0.82, 0.68, 0.42))
			_add_card_text(card_node, "✦", Vector3(0, 0.041, 0.34), 42, Color(0.88, 0.68, 0.3))
		else:
			var label := Rules.card_label(hand[index])
			var rank_text := label.substr(0, label.length() - 1)
			var suit_text := label.substr(label.length() - 1, 1)
			var ink := Color(0.65, 0.08, 0.08) if int(hand[index].suit) in [1, 2] else Color(0.05, 0.06, 0.07)
			_add_card_text(card_node, suit_text, Vector3(0, 0.041, 0.0), 112, ink)
			_add_card_text(card_node, rank_text + suit_text, Vector3(-0.25, 0.041, -0.36), 32, ink)
			_add_card_text(card_node, rank_text + suit_text, Vector3(0.25, 0.041, 0.36), 32, ink, 180)

func _add_card_text(parent: Node3D, value: String, card_position: Vector3, font_size: int, color: Color, rotation_y: float = 0.0) -> void:
	var face := Label3D.new()
	face.text = value
	face.font_size = font_size
	face.pixel_size = 0.0024
	face.position = card_position
	face.rotation_degrees = Vector3(-90, rotation_y, 0)
	face.modulate = color
	face.no_depth_test = true
	parent.add_child(face)

func _add_card_border(parent: Node3D, color: Color) -> void:
	var edge_specs := [
		[Vector3(0.68, 0.008, 0.018), Vector3(0, 0.032, -0.48)],
		[Vector3(0.68, 0.008, 0.018), Vector3(0, 0.032, 0.48)],
		[Vector3(0.018, 0.008, 0.94), Vector3(-0.33, 0.032, 0)],
		[Vector3(0.018, 0.008, 0.94), Vector3(0.33, 0.032, 0)]
	]
	for edge_spec in edge_specs:
		var edge := MeshInstance3D.new()
		var edge_mesh := BoxMesh.new()
		edge_mesh.size = edge_spec[0]
		edge.mesh = edge_mesh
		edge.position = edge_spec[1]
		edge.material_override = _material(color, 0.28)
		parent.add_child(edge)

func _update_ui() -> void:
	var dealer_value := "?" if round_active and not dealer_revealed else str(Rules.hand_value(dealer_hand))
	dealer_label.text = "DEALER  %s  |  %d cards" % [dealer_value, dealer_hand.size()]
	player_label.text = "YOU  %d  |  %d cards  |  Bet: %d" % [Rules.hand_value(player_hand), player_hand.size(), current_bet]
	chips_label.text = "CHIPS  %d" % chips
	var opponent_profile := _current_opponent_profile()
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
	status_label.accessibility_name = "Game status: " + status_label.text
	dealer_label.accessibility_name = "Dealer hand: " + dealer_label.text
	player_label.accessibility_name = "Your hand: " + player_label.text
	chips_label.accessibility_name = "Chips: " + chips_label.text
	opponent_label.accessibility_name = "Current opponent: " + opponent_label.text
	event_label.accessibility_name = "Current table event: " + event_label.text
	survival_label.accessibility_name = "Survival progress: " + survival_label.text
	medkit_button.accessibility_name = "Medkit, 75 chips, " + ("already used" if survival.medkit_used else "available")
	marked_button.accessibility_name = "Marked Card, %d uses remaining" % items.marked_cards
	bell_button.accessibility_name = "House Bell, %s" % ("active" if house_bell_active else "%d uses remaining" % items.house_bells)
	archive_button.accessibility_name = "Survival archive, %d of 6 entries unlocked" % progression.unlocked_count()
	restart_button.accessibility_name = "Restart run"
