extends SceneTree

const Rules = preload("res://scripts/blackjack_rules.gd")
const SurvivalRunState = preload("res://scripts/survival_run.gd")
const Opponents = preload("res://scripts/opponent_profiles.gd")
const SurvivalItemsState = preload("res://scripts/survival_items.gd")
const SaveSystem = preload("res://scripts/survival_save.gd")
const EncounterEventsState = preload("res://scripts/encounter_events.gd")
const ProgressionState = preload("res://scripts/progression.gd")
const ControllerInput = preload("res://scripts/controller_input.gd")
const AccessibilityLayout = preload("res://scripts/accessibility_layout.gd")

var failures := 0

func _initialize() -> void:
	_test_values()
	_test_aces()
	_test_outcomes()
	_test_natural_blackjack_priority()
	_test_soft_hands_and_opponent_profiles()
	_test_survival_progression()
	_test_survival_items()
	_test_save_system()
	_test_encounter_events()
	_test_save_migration()
	_test_persistent_progression()
	_test_controller_input_mapping()
	_test_responsive_ui_scale()
	if failures > 0:
		push_error("Survival 21 test suite failed with %d assertion(s)." % failures)
		quit(1)
	else:
		print("All Survival 21 tests passed.")
		quit()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAILED: " + message)

func _test_values() -> void:
	_expect(Rules.hand_value([{"rank": 10}, {"rank": 9}]) == 19, "10 + 9 should equal 19")
	_expect(Rules.hand_value([{"rank": 1}, {"rank": 13}]) == 21, "Ace + King should equal 21")
	_expect(Rules.is_blackjack([{"rank": 1}, {"rank": 10}]), "Two-card 21 should be blackjack")
	_expect(not Rules.is_blackjack([{"rank": 7}, {"rank": 7}, {"rank": 7}]), "Three-card 21 is not blackjack")

func _test_aces() -> void:
	_expect(Rules.hand_value([{"rank": 1}, {"rank": 1}, {"rank": 9}]) == 21, "Multiple aces should downgrade safely")
	_expect(Rules.hand_value([{"rank": 1}, {"rank": 9}, {"rank": 5}]) == 15, "Soft ace should downgrade on bust")

func _test_natural_blackjack_priority() -> void:
	var natural := [{"rank": 1}, {"rank": 13}]
	var ordinary_21 := [{"rank": 7}, {"rank": 7}, {"rank": 7}]
	_expect(Rules.outcome(natural, natural) == "push", "Two natural blackjacks should push")
	_expect(Rules.outcome(natural, ordinary_21) == "win", "Natural blackjack should beat a three-card 21")
	_expect(Rules.outcome(ordinary_21, natural) == "lose", "Dealer natural blackjack should beat a three-card 21")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], natural) == "lose", "Dealer natural blackjack should beat a non-natural player hand")

func _test_soft_hands_and_opponent_profiles() -> void:
	var whispering := EncounterEventsState.event_for_round(6)
	var rust_storm := EncounterEventsState.event_for_round(7)
	var debt := EncounterEventsState.event_for_round(8)
	_expect(whispering.get("id") == "WHISPERING_TABLE", "Round six should use Whispering Table")
	_expect(EncounterEventsState.win_bonus_for(whispering, false) == 15, "Whispering Table should add fifteen chips to a normal win")
	_expect(rust_storm.get("id") == "RUST_STORM", "Round seven should use Rust Storm")
	_expect(EncounterEventsState.loss_tax_for(rust_storm, true) == 15, "Rust Storm should tax a player bust")
	_expect(EncounterEventsState.loss_tax_for(rust_storm, false) == 0, "Rust Storm should not tax a non-bust loss")
	_expect(debt.get("id") == "DEALERS_DEBT", "Round eight should use Dealer's Debt")
	_expect(EncounterEventsState.win_bonus_for(debt, true) == 20, "Dealer's Debt should pay twenty chips when the dealer busts")
	_expect(EncounterEventsState.win_bonus_for(debt, false) == 0, "Dealer's Debt should not pay if the dealer does not bust")
	var soft_seventeen := [{"rank": 1}, {"rank": 6}]
	var hard_seventeen := [{"rank": 10}, {"rank": 7}]
	_expect(Rules.is_soft(soft_seventeen), "Ace + 6 should be a soft 17")
	_expect(not Rules.is_soft(hard_seventeen), "10 + 7 should be a hard 17")
	_expect(not Rules.is_soft([{"rank": 1}, {"rank": 9}, {"rank": 7}]), "Downgraded ace should not remain soft")
	_expect(not Opponents.should_dealer_hit(soft_seventeen, 0), "Night Dealer should stand on soft 17")
	_expect(Opponents.should_dealer_hit(soft_seventeen, 2), "Collector should hit soft 17")
	_expect(Opponents.should_dealer_hit(hard_seventeen, 4), "The House should draw on hard 17 and stand at 18")
	_expect(not Opponents.should_dealer_hit(hard_seventeen, 0), "Night Dealer should stand on hard 17")
	_expect(not Opponents.should_dealer_hit(soft_seventeen, 2, true), "House Bell should stop the dealer even when the Collector would hit soft 17")
	_expect(Opponents.profile_for_wins(0).get("name") == "THE NIGHT DEALER", "First opponent profile should be Night Dealer")
	_expect(Opponents.profile_for_wins(2).get("name") == "THE COLLECTOR", "Second opponent profile should be Collector")
	_expect(Opponents.profile_for_wins(4).get("name") == "THE HOUSE", "Final opponent profile should be The House")

func _test_outcomes() -> void:
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 7}]) == "win", "Higher hand should win")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 8}]) == "push", "Equal hands should push")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 9}, {"rank": 5}], [{"rank": 10}, {"rank": 7}]) == "lose", "Player bust should lose")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 9}, {"rank": 5}]) == "win", "Dealer bust should lose")

func _test_encounter_events() -> void:
	var quiet := EncounterEventsState.event_for_round(1)
	var restless := EncounterEventsState.event_for_round(3)
	var favor := EncounterEventsState.event_for_round(4)
	var toll := EncounterEventsState.event_for_round(5)
	_expect(quiet.get("id") == "QUIET_TABLE", "Ordinary rounds should use the quiet-table event")
	_expect(restless.get("force_soft_17", false), "Every third round should force soft-17 dealer draws")
	_expect(favor.get("push_bonus", 0) == 10, "House Favor should add ten chips on a push")
	_expect(toll.get("loss_tax", 0) == 10, "Blood Toll should charge ten extra chips after a loss")
	var soft_seventeen := [{"rank": 1}, {"rank": 6}]
	_expect(Opponents.should_dealer_hit(soft_seventeen, 0, false, true), "Restless Dealer event should override Night Dealer soft-17 behavior")
	_expect(not Opponents.should_dealer_hit(soft_seventeen, 0, true, true), "House Bell should override the Restless Dealer event")

func _test_save_system() -> void:
	var path := "user://survival21_test.cfg"
	var state := {
		"save_version": SaveSystem.SAVE_VERSION,
		"chips": 325,
		"health": 2,
		"wins": 1,
		"losses": 1,
		"pushes": 0,
		"medkit_used": true,
		"finished": false,
		"ending": "",
		"marked_cards": 0,
		"house_bells": 1
	}
	_expect(SaveSystem.save_state(state, path), "Save file should be written")
	var loaded := SaveSystem.load_state(path)
	_expect(int(loaded.get("chips", 0)) == 325, "Saved chips should round-trip")
	_expect(int(loaded.get("health", 0)) == 2, "Saved health should round-trip")
	_expect(int(loaded.get("marked_cards", -1)) == 0, "Saved item counts should round-trip")
	SaveSystem.delete_state(path)
	_expect(SaveSystem.load_state(path).is_empty(), "Deleted save should no longer load")

func _test_survival_items() -> void:
	var items := SurvivalItemsState.new()
	_expect(items.marked_cards == 1 and items.house_bells == 1, "Run should start with one of each tactical item")
	_expect(not items.use_marked_card(false), "Marked card cannot be used outside an active hand")
	_expect(items.use_marked_card(true), "Marked card should reveal one dealer card during an active hand")
	_expect(items.marked_cards == 0 and not items.use_marked_card(true), "Marked card should be single-use")
	_expect(items.use_house_bell(true), "House Bell should arm during an active hand")
	_expect(items.house_bells == 0 and not items.use_house_bell(true), "House Bell should be single-use")
	items.reset()
	_expect(items.marked_cards == 1 and items.house_bells == 1, "Restart should restore tactical items")

func _test_survival_progression() -> void:
	var run := SurvivalRunState.new()
	_expect(run.health == 3 and run.wins == 0, "Run should start with three health and zero wins")
	run.resolve_hand("lose")
	_expect(run.health == 2 and not run.finished, "A loss should cost one health")
	_expect(run.use_medkit(100), "Medkit should work once when affordable and injured")
	_expect(run.health == 3 and run.medkit_used, "Medkit should restore one health")
	_expect(not run.use_medkit(100), "Medkit must not be reusable")
	run.resolve_hand("win")
	run.resolve_hand("push")
	_expect(run.wins == 1 and run.pushes == 1, "Wins and pushes should be tracked separately")
	run.resolve_hand("lose")
	run.resolve_hand("lose")
	run.resolve_hand("lose")
	_expect(run.finished and run.ending == "defeat" and run.health == 0, "Three health losses should end the run")
	run.reset()
	for i in range(5):
		run.resolve_hand("win")
	_expect(run.finished and run.ending == "victory", "Five wins should complete the run")

func _test_save_migration() -> void:
	var path := "user://survival21_legacy_test.cfg"
	var legacy := ConfigFile.new()
	legacy.set_value("state", "save_version", 1)
	legacy.set_value("state", "chips", 275)
	legacy.set_value("state", "health", 2)
	legacy.set_value("state", "wins", 1)
	_expect(legacy.save(path) == OK, "Legacy v1 save should be written")
	var migrated := SaveSystem.load_state(path)
	_expect(int(migrated.get("save_version", 0)) == SaveSystem.SAVE_VERSION, "Version 1 save should migrate to current version")
	_expect(int(migrated.get("chips", 0)) == 275, "Migration should preserve chips")
	_expect(int(migrated.get("round_number", -1)) == 0, "Migration should add missing round defaults")
	_expect(int(migrated.get("marked_cards", -1)) == 1, "Migration should restore missing marked-card default")
	var upgraded := ConfigFile.new()
	_expect(upgraded.load(path) == OK and int(upgraded.get_value("state", "save_version", 0)) == SaveSystem.SAVE_VERSION, "Migrated save should be persisted at the new version")
	SaveSystem.delete_state(path)

func _test_responsive_ui_scale() -> void:
	var landscape := AccessibilityLayout.fit_scale(Vector2(1280, 720), Vector2(460, 470))
	var compact_phone := AccessibilityLayout.fit_scale(Vector2(360, 800), Vector2(460, 470))
	var small_landscape := AccessibilityLayout.fit_scale(Vector2(320, 480), Vector2(460, 470))
	_expect(is_equal_approx(landscape, 1.0), "Large landscape viewport should keep the default layout scale")
	_expect(compact_phone < 1.0 and compact_phone > 0.5, "Compact phone viewport should scale the interface down")
	_expect(small_landscape < compact_phone, "Smaller viewport should use a smaller interface scale")
	_expect(AccessibilityLayout.fit_scale(Vector2.ZERO, Vector2(460, 470)) == 1.0, "Invalid viewport should use a safe default scale")

func _test_controller_input_mapping() -> void:
	_expect(ControllerInput.action_for_button(JOY_BUTTON_A) == "hit", "Gamepad A should hit")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_B) == "stand", "Gamepad B should stand")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_X) == "double", "Gamepad X should double")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_Y) == "next_hand", "Gamepad Y should start the next hand")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_LEFT_SHOULDER) == "marked_card", "Left shoulder should use Marked Card")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_RIGHT_SHOULDER) == "house_bell", "Right shoulder should use House Bell")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_START) == "restart", "Start should restart after a run ends")
	_expect(ControllerInput.action_for_button(JOY_BUTTON_BACK) == "", "Unmapped gamepad buttons should be ignored")

func _test_persistent_progression() -> void:
	var path := "user://survival21_profile_test.cfg"
	var profile := ProgressionState.new()
	profile.record_hand("win", "THE COLLECTOR", "")
	profile.record_item_use("marked_card")
	profile.record_item_use("house_bell")
	_expect(profile.unlocked.has("FIRST_HAND"), "First completed hand should unlock its archive entry")
	_expect(profile.unlocked.has("COLLECTOR"), "Defeating Collector should unlock its archive entry")
	_expect(profile.unlocked.has("RELIC_PAIR"), "Using both tactical items should unlock their archive entry")
	for i in range(8):
		profile.record_hand("push", "THE NIGHT DEALER", "")
	_expect(not profile.unlocked.has("TEN_HANDS"), "Nine completed hands should not unlock the regular entry")
	profile.record_hand("win", "THE HOUSE", "victory")
	_expect(profile.unlocked.has("TEN_HANDS"), "Ten completed hands should unlock the regular entry")
	_expect(profile.unlocked.has("HOUSE") and profile.unlocked.has("ESCAPE"), "Defeating The House and escaping should unlock both entries")
	_expect(profile.save_profile(path), "Progression profile should save")
	var restored := ProgressionState.new()
	restored.load_profile(path)
	_expect(restored.unlocked_count() == 6, "All six archive unlocks should survive reload")
	_expect(restored.hands_played == 10, "Lifetime hand count should survive reload")
	_expect(restored.archive_text().contains("OUT THE DOOR"), "Unlocked archive text should be readable")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
