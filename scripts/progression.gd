class_name SurvivalProgression
extends RefCounted

const PROFILE_PATH := "user://survival21_profile.cfg"
const ACHIEVEMENTS := [
	{"id": "FIRST_HAND", "title": "THE FIRST DEAL", "description": "Complete your first hand.", "lore": "The dealer never blinks. The first card is always a warning."},
	{"id": "COLLECTOR", "title": "THE COLLECTOR", "description": "Defeat the Collector.", "lore": "He collects more than chips. He keeps the names of everyone who sat here."},
	{"id": "HOUSE", "title": "BREAK THE HOUSE", "description": "Defeat The House.", "lore": "The final dealer has no face beneath the hood. Only the table remains."},
	{"id": "ESCAPE", "title": "OUT THE DOOR", "description": "Win a survival run.", "lore": "The exit opens only after five victories. The silence outside is worse."},
	{"id": "TEN_HANDS", "title": "OLD REGULAR", "description": "Complete ten hands across all runs.", "lore": "The felt remembers every hand. It remembers you, too."},
	{"id": "RELIC_PAIR", "title": "TWO LAST CHANCES", "description": "Use both tactical items.", "lore": "The marked card and the House Bell were never meant to be used together."}
]

var hands_played := 0
var wins := 0
var losses := 0
var pushes := 0
var marked_uses := 0
var bell_uses := 0
var unlocked: Array[String] = []

func load_profile(path: String = PROFILE_PATH) -> void:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	hands_played = maxi(0, int(config.get_value("profile", "hands_played", 0)))
	wins = maxi(0, int(config.get_value("profile", "wins", 0)))
	losses = maxi(0, int(config.get_value("profile", "losses", 0)))
	pushes = maxi(0, int(config.get_value("profile", "pushes", 0)))
	marked_uses = maxi(0, int(config.get_value("profile", "marked_uses", 0)))
	bell_uses = maxi(0, int(config.get_value("profile", "bell_uses", 0)))
	var saved: Variant = config.get_value("profile", "unlocked", [])
	unlocked.clear()
	if saved is Array:
		for achievement in saved:
			if _achievement_exists(str(achievement)) and not unlocked.has(str(achievement)):
				unlocked.append(str(achievement))
	_refresh_unlocks("")

func save_profile(path: String = PROFILE_PATH) -> bool:
	var config := ConfigFile.new()
	config.set_value("profile", "profile_version", 1)
	config.set_value("profile", "hands_played", hands_played)
	config.set_value("profile", "wins", wins)
	config.set_value("profile", "losses", losses)
	config.set_value("profile", "pushes", pushes)
	config.set_value("profile", "marked_uses", marked_uses)
	config.set_value("profile", "bell_uses", bell_uses)
	config.set_value("profile", "unlocked", unlocked)
	return config.save(path) == OK

func record_item_use(item_id: String) -> void:
	if item_id == "marked_card":
		marked_uses += 1
	elif item_id == "house_bell":
		bell_uses += 1
	_refresh_unlocks("")

func record_hand(result: String, opponent_name: String, ending: String) -> void:
	hands_played += 1
	match result:
		"win": wins += 1
		"lose": losses += 1
		"push": pushes += 1
	_refresh_unlocks(opponent_name if result == "win" else "")
	if ending == "victory":
		_unlock("ESCAPE")

func _refresh_unlocks(defeated_opponent: String) -> void:
	if hands_played >= 1:
		_unlock("FIRST_HAND")
	if defeated_opponent == "THE COLLECTOR":
		_unlock("COLLECTOR")
	if defeated_opponent == "THE HOUSE":
		_unlock("HOUSE")
	if hands_played >= 10:
		_unlock("TEN_HANDS")
	if marked_uses > 0 and bell_uses > 0:
		_unlock("RELIC_PAIR")

func _unlock(achievement_id: String) -> void:
	if _achievement_exists(achievement_id) and not unlocked.has(achievement_id):
		unlocked.append(achievement_id)

func _achievement_exists(achievement_id: String) -> bool:
	for entry in ACHIEVEMENTS:
		if entry.id == achievement_id:
			return true
	return false

func unlocked_count() -> int:
	return unlocked.size()

func archive_text() -> String:
	var lines := PackedStringArray()
	lines.append("PROFILE  |  %d HANDS  |  %d WINS  |  %d LOSSES  |  %d PUSHES" % [hands_played, wins, losses, pushes])
	lines.append("")
	for entry in ACHIEVEMENTS:
		var is_unlocked := unlocked.has(str(entry.id))
		lines.append(("%s  %s" % ["[UNLOCKED]", entry.title]) if is_unlocked else ("[LOCKED]  %s" % entry.title))
		lines.append(entry.lore if is_unlocked else entry.description)
		lines.append("")
	return "\n".join(lines)
