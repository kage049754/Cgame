class_name OpponentProfiles
extends RefCounted

const BlackjackRules = preload("res://scripts/blackjack_rules.gd")

static func tier_for_wins(wins: int, starting_tier: int = 0) -> int:
	return clampi(clampi(starting_tier, 0, 2) + maxi(0, wins) / 2, 0, 2)

static func highest_unlocked_tier(requested_tier: int, unlocked: Array) -> int:
	var requested := clampi(requested_tier, 0, 2)
	if requested >= 2 and unlocked.has("HOUSE"):
		return 2
	if requested >= 1 and unlocked.has("COLLECTOR"):
		return 1
	return 0

static func profile_for_tier(tier: int) -> Dictionary:
	match clampi(tier, 0, 2):
		2:
			return {
				"id": "HOUSE",
				"name": "THE HOUSE",
				"tell": "Stands on 18",
				"stand_at": 18,
				"hit_soft_17": true
			}
		1:
			return {
				"id": "COLLECTOR",
				"name": "THE COLLECTOR",
				"tell": "Hits soft 17",
				"stand_at": 17,
				"hit_soft_17": true
			}
		_:
			return {
				"id": "NIGHT_DEALER",
				"name": "THE NIGHT DEALER",
				"tell": "Stands on soft 17",
				"stand_at": 17,
				"hit_soft_17": false
			}

static func profile_for_wins(wins: int, starting_tier: int = 0) -> Dictionary:
	return profile_for_tier(tier_for_wins(wins, starting_tier))

static func should_dealer_hit(cards: Array, wins: int, house_bell_active: bool = false, force_soft_17: bool = false, starting_tier: int = 0) -> bool:
	if house_bell_active:
		return false
	var profile := profile_for_wins(wins, starting_tier)
	var value := BlackjackRules.hand_value(cards)
	var stand_at := int(profile.get("stand_at", 17))
	if value < stand_at:
		return true
	if value == 17 and (bool(profile.get("hit_soft_17", false)) or force_soft_17) and BlackjackRules.is_soft(cards):
		return true
	return false
