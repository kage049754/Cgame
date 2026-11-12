class_name EncounterEvents
extends RefCounted

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
	if round_number > 0 and round_number % 4 == 0:
		return {
			"id": "HOUSE_FAVOR",
			"name": "HOUSE FAVOR",
			"description": "A push returns 10 bonus chips.",
			"loss_tax": 0,
			"push_bonus": 10,
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
