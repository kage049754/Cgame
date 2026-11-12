extends SceneTree

const Rules = preload("res://scripts/blackjack_rules.gd")

func _initialize() -> void:
	_test_values()
	_test_aces()
	_test_outcomes()
	_test_natural_blackjack_priority()
	print("All Survival 21 blackjack rule tests passed.")
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

func _test_outcomes() -> void:
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 7}]) == "win", "Higher hand should win")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 8}]) == "push", "Equal hands should push")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 9}, {"rank": 5}], [{"rank": 10}, {"rank": 7}]) == "lose", "Player bust should lose")
	_expect(Rules.outcome([{"rank": 10}, {"rank": 8}], [{"rank": 10}, {"rank": 9}, {"rank": 5}]) == "win", "Dealer bust should lose")
	print("All Survival 21 blackjack rule tests passed.")
