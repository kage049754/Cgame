class_name BlackjackRules
extends RefCounted

const TARGET := 21

static func hand_value(cards: Array) -> int:
	var total := 0
	var aces := 0
	for card in cards:
		var rank: int = int(card.get("rank", 0))
		if rank == 1:
			aces += 1
			total += 11
		elif rank >= 10:
			total += 10
		else:
			total += rank
	while total > TARGET and aces > 0:
		total -= 10
		aces -= 1
	return total

static func is_blackjack(cards: Array) -> bool:
	return cards.size() == 2 and hand_value(cards) == TARGET

static func is_bust(cards: Array) -> bool:
	return hand_value(cards) > TARGET

static func outcome(player_cards: Array, dealer_cards: Array) -> String:
	var player_natural := is_blackjack(player_cards)
	var dealer_natural := is_blackjack(dealer_cards)
	if player_natural and dealer_natural:
		return "push"
	if dealer_natural:
		return "lose"
	if player_natural:
		return "win"
	var player := hand_value(player_cards)
	var dealer := hand_value(dealer_cards)
	if player > TARGET:
		return "lose"
	if dealer > TARGET:
		return "win"
	if player > dealer:
		return "win"
	if player < dealer:
		return "lose"
	return "push"

static func card_label(card: Dictionary) -> String:
	var suits := ["♠", "♥", "♦", "♣"]
	var rank: int = int(card.get("rank", 1))
	var names := {1: "A", 11: "J", 12: "Q", 13: "K"}
	var face := str(names.get(rank, rank))
	var suit_index: int = clampi(int(card.get("suit", 0)), 0, 3)
	return face + suits[suit_index]
