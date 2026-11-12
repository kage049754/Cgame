extends SceneTree

const Rules = preload("res://scripts/blackjack_rules.gd")
const SurvivalRunState = preload("res://scripts/survival_run.gd")
const Opponents = preload("res://scripts/opponent_profiles.gd")
const SurvivalItemsState = preload("res://scripts/survival_items.gd")
const SaveSystem = preload("res://scripts/survival_save.gd")
const EncounterEventsState = preload("res://scripts/encounter_events.gd")

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
	print("All Survival 21 tests passed.")
	quit()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAILED: " + message)
		quit(1)

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
