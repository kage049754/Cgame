class_name SurvivalSave
extends RefCounted

const SAVE_PATH := "user://survival21.cfg"
const SAVE_VERSION := 2

static func save_state(state: Dictionary, path: String = SAVE_PATH) -> bool:
	var config := ConfigFile.new()
	for key in state.keys():
		config.set_value("state", str(key), state[key])
	return config.save(path) == OK

static func load_state(path: String = SAVE_PATH) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return {}
	var state: Dictionary = {}
	for key in config.get_section_keys("state"):
		state[key] = config.get_value("state", key)
	var stored_version := int(state.get("save_version", 0))
	if stored_version == 1:
		state["save_version"] = SAVE_VERSION
		state["round_number"] = maxi(0, int(state.get("round_number", 0)))
		state["marked_cards"] = clampi(int(state.get("marked_cards", 1)), 0, 1)
		state["house_bells"] = clampi(int(state.get("house_bells", 1)), 0, 1)
		state["ending"] = str(state.get("ending", ""))
		save_state(state, path)
	elif stored_version != SAVE_VERSION:
		return {}
	return state

static func delete_state(path: String = SAVE_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
