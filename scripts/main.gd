extends Node3D

const Rules = preload("res://scripts/blackjack_rules.gd")
const Opponents = preload("res://scripts/opponent_profiles.gd")
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
var medkit_button: Button
var survival := SurvivalRun.new()
var hit_button: Button
var stand_button: Button
var deal_button: Button
var double_button: Button
var cards_root: Node3D

func _ready() -> void:
	_build_table()
	_build_ui()
	_new_round()

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

func _material(color: Color, roughness: float = 0.65) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(22, 18)
	panel.size = Vector2(410, 265)
	layer.add_child(panel)
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
	medkit_button = _make_button("MEDKIT (75)", _on_medkit)
	column.add_child(medkit_button)

	var hint := Label.new()
	hint.text = "Beat the dealer. Don't go over 21."
	hint.add_theme_color_override("font_color", Color(0.72, 0.78, 0.75))
	column.add_child(hint)

func _make_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(86, 42)
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
	status_label.text = "Round %d — choose your move." % round_number
	if Rules.is_blackjack(player_hand) or Rules.is_blackjack(dealer_hand):
		_finish_round()
	_update_ui()
	_render_cards()

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
	while Opponents.should_dealer_hit(dealer_hand, survival.wins):
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
		while Rules.hand_value(dealer_hand) < 17:
			_draw_card(dealer_hand)
	_finish_round()
	_update_ui()
	_render_cards()

func _on_next_hand() -> void:
	if not round_active and not survival.finished:
		_new_round()

func _on_medkit() -> void:
	if survival.use_medkit(chips):
		chips -= 75
		status_label.text = "Medkit used. One heart restored."
		_update_ui()

func _finish_round() -> void:
	if not round_active:
		return
	round_active = false
	var result := Rules.outcome(player_hand, dealer_hand)
	survival.resolve_hand(result)
	if Rules.is_blackjack(player_hand) and result == "win":
		chips += int(round(float(current_bet) * 2.5))
		status_label.text = "BLACKJACK! You win 3:2."
	elif result == "win":
		chips += current_bet * 2
		status_label.text = "You survived this hand. You win."
	elif result == "push":
		chips += current_bet
		status_label.text = "Push. Your bet is returned."
	else:
		status_label.text = "You lost this hand."
	if survival.ending == "victory":
		status_label.text = "THE HOUSE IS BROKEN. YOU SURVIVED."
	elif survival.ending == "defeat":
		status_label.text = "YOUR LAST HEART FADES. THE HOUSE WINS."
	_update_ui()

func _render_cards() -> void:
	for child in cards_root.get_children():
		child.queue_free()
	_add_hand_visuals(player_hand, Vector3(-1.65, 0.34, 1.45), false)
	_add_hand_visuals(dealer_hand, Vector3(-1.65, 0.34, -1.25), round_active)

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
	var dealer_value := "?" if round_active else str(Rules.hand_value(dealer_hand))
	dealer_label.text = "DEALER  %s  |  %d cards" % [dealer_value, dealer_hand.size()]
	player_label.text = "YOU  %d  |  %d cards  |  Bet: %d" % [Rules.hand_value(player_hand), player_hand.size(), current_bet]
	chips_label.text = "CHIPS  %d" % chips
	var opponent_profile := Opponents.profile_for_wins(survival.wins)
	opponent_label.text = "OPPONENT  %s — %s" % [opponent_profile.get("name", "UNKNOWN"), opponent_profile.get("tell", "")]
	survival_label.text = "HEARTS  %s   |   WINS  %d / %d   |   LOSSES  %d" % ["♥".repeat(survival.health) + "♡".repeat(SurvivalRun.MAX_HEALTH - survival.health), survival.wins, SurvivalRun.REQUIRED_WINS, survival.losses]
	hit_button.disabled = not round_active
	stand_button.disabled = not round_active
	double_button.disabled = not round_active or player_hand.size() != 2 or chips < current_bet
	deal_button.disabled = round_active or chips <= 0 or survival.finished
	medkit_button.disabled = survival.finished or survival.medkit_used or survival.health >= SurvivalRun.MAX_HEALTH or chips < 75
