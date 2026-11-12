class_name SurvivalSave
extends RefCounted

const SAVE_PATH := "user://survival21.cfg"
const SAVE_VERSION := 1

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
	if int(state.get("save_version", 0)) != SAVE_VERSION:
		return {}
	return state

static func delete_state(path: String = SAVE_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
