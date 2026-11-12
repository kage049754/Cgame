class_name GameSettingsStore
extends RefCounted

const SETTINGS_PATH := "user://settings.cfg"

static func save_settings(settings: Dictionary, path: String = SETTINGS_PATH) -> bool:
	var config := ConfigFile.new()
	for key in settings.keys():
		config.set_value("audio", str(key), settings[key])
	return config.save(path) == OK

static func load_settings(path: String = SETTINGS_PATH) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return {"ambience_percent": 4.0, "effects_percent": 35.0, "ui_scale": 1.0, "high_contrast": false, "starting_opponent_tier": 0}
	return {
		"ambience_percent": float(config.get_value("audio", "ambience_percent", 4.0)),
		"effects_percent": float(config.get_value("audio", "effects_percent", 35.0)),
		"ui_scale": clampf(float(config.get_value("audio", "ui_scale", 1.0)), 0.8, 1.3),
		"high_contrast": bool(config.get_value("audio", "high_contrast", false)),
		"starting_opponent_tier": clampi(int(config.get_value("audio", "starting_opponent_tier", 0)), 0, 2)
	}
