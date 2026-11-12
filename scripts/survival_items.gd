class_name SurvivalItems
extends RefCounted

const STARTING_MARKED_CARDS := 1
const STARTING_HOUSE_BELLS := 1

var marked_cards: int = STARTING_MARKED_CARDS
var house_bells: int = STARTING_HOUSE_BELLS

func use_marked_card(round_active: bool) -> bool:
	if not round_active or marked_cards <= 0:
		return false
	marked_cards -= 1
	return true

func use_house_bell(round_active: bool) -> bool:
	if not round_active or house_bells <= 0:
		return false
	house_bells -= 1
	return true

func reset() -> void:
	marked_cards = STARTING_MARKED_CARDS
	house_bells = STARTING_HOUSE_BELLS
