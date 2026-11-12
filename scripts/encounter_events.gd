class_name EncounterEvents
extends RefCounted

static func win_bonus_for(event: Dictionary, dealer_bust: bool) -> int:
	return int(event.get("win_bonus", 0)) + (int(event.get("dealer_bust_bonus", 0)) if dealer_bust else 0)

static func loss_tax_for(event: Dictionary, player_bust: bool) -> int:
	return int(event.get("loss_tax", 0)) + (int(event.get("player_bust_tax", 0)) if player_bust else 0)

static func event_for_round(round_number: int) -> Dictionary:
	if round_number > 0 and round_number % 5 == 0:
		return {
			"id": "BLOOD_TOLL",
			"name": "BLOOD TOLL",
			"description": "A loss costs 10 extra chips.",
			"loss_tax": 10,
			"push_bonus": 0,
			"force_soft_17": false
		}
	if round_number > 0 and round_number % 8 == 0:
		return {
			"id": "DEALERS_DEBT",
			"name": "DEALER'S DEBT",
			"description": "Beat the dealer for 20 extra chips when the dealer busts.",
			"loss_tax": 0,
			"push_bonus": 0,
			"win_bonus": 0,
			"dealer_bust_bonus": 20,
			"player_bust_tax": 0,
			"force_soft_17": false
		}
	if round_number > 0 and round_number % 4 == 0:
		return {
			"id": "HOUSE_FAVOR",
			"name": "HOUSE FAVOR",
			"description": "A push returns 10 bonus chips.",
			"loss_tax": 0,
			"push_bonus": 10,
			"force_soft_17": false
		}
	if round_number > 0 and round_number % 7 == 0:
		return {
			"id": "RUST_STORM",
			"name": "RUST STORM",
			"description": "A player bust costs 15 extra chips.",
			"loss_tax": 0,
			"push_bonus": 0,
			"win_bonus": 0,
			"dealer_bust_bonus": 0,
			"player_bust_tax": 15,
			"force_soft_17": false
		}
	if round_number > 0 and round_number % 6 == 0:
		return {
			"id": "WHISPERING_TABLE",
			"name": "WHISPERING TABLE",
			"description": "Every win pays 15 extra chips.",
			"loss_tax": 0,
			"push_bonus": 0,
			"win_bonus": 15,
			"dealer_bust_bonus": 0,
			"player_bust_tax": 0,
			"force_soft_17": false
		}
	if round_number > 0 and round_number % 3 == 0:
		return {
			"id": "RESTLESS_DEALER",
			"name": "RESTLESS DEALER",
			"description": "The dealer hits soft 17 this hand.",
			"loss_tax": 0,
			"push_bonus": 0,
			"force_soft_17": true
		}
	return {
		"id": "QUIET_TABLE",
		"name": "QUIET TABLE",
		"description": "No special rule this hand.",
		"loss_tax": 0,
		"push_bonus": 0,
		"force_soft_17": false
	}
