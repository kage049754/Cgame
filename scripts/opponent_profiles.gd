class_name OpponentProfiles
extends RefCounted

const BlackjackRules = preload("res://scripts/blackjack_rules.gd")

static func profile_for_wins(wins: int) -> Dictionary:
	if wins >= 4:
		return {
			"name": "THE HOUSE",
			"tell": "Stands on 18",
			"stand_at": 18,
			"hit_soft_17": true
		}
	if wins >= 2:
		return {
			"name": "THE COLLECTOR",
			"tell": "Hits soft 17",
			"stand_at": 17,
			"hit_soft_17": true
		}
	return {
		"name": "THE NIGHT DEALER",
		"tell": "Stands on soft 17",
		"stand_at": 17,
		"hit_soft_17": false
	}

static func should_dealer_hit(cards: Array, wins: int, house_bell_active: bool = false) -> bool:
	if house_bell_active:
		return false
	var profile := profile_for_wins(wins)
	var value := BlackjackRules.hand_value(cards)
	var stand_at := int(profile.get("stand_at", 17))
	if value < stand_at:
		return true
	if value == 17 and bool(profile.get("hit_soft_17", false)) and BlackjackRules.is_soft(cards):
		return true
	return false
