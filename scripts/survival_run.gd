class_name SurvivalRun
extends RefCounted

const STARTING_HEALTH := 3
const MAX_HEALTH := 3
const REQUIRED_WINS := 5

var health: int = STARTING_HEALTH
var wins: int = 0
var losses: int = 0
var pushes: int = 0
var medkit_used: bool = false
var finished: bool = false
var ending: String = ""

func resolve_hand(result: String) -> void:
	if finished:
		return
	match result:
		"win":
			wins += 1
			health = mini(MAX_HEALTH, health + 1)
		"lose":
			losses += 1
			health -= 1
			if health <= 0:
				health = 0
				finished = true
				ending = "defeat"
		"push":
			pushes += 1
	if wins >= REQUIRED_WINS and not finished:
		finished = true
		ending = "victory"

func use_medkit(chips: int) -> bool:
	if finished or medkit_used or health >= MAX_HEALTH or chips < 75:
		return false
	medkit_used = true
	health = mini(MAX_HEALTH, health + 1)
	return true

func opponent_name() -> String:
	if wins >= 4:
		return "THE HOUSE"
	if wins >= 2:
		return "THE COLLECTOR"
	return "THE NIGHT DEALER"

func reset() -> void:
	health = STARTING_HEALTH
	wins = 0
	losses = 0
	pushes = 0
	medkit_used = false
	finished = false
	ending = ""
