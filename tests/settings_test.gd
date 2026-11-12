extends SceneTree

const SettingsStore = preload("res://scripts/settings_store.gd")

func _initialize() -> void:
	var path := "user://settings_test.cfg"
	var values := {"ambience_percent": 12.0, "effects_percent": 68.0, "ui_scale": 1.25, "high_contrast": true, "starting_opponent_tier": 2}
	if not SettingsStore.save_settings(values, path):
		push_error("Could not save settings.")
		quit(1)
		return
	var loaded := SettingsStore.load_settings(path)
	if not is_equal_approx(float(loaded.get("ambience_percent", 0.0)), 12.0):
		push_error("Ambience setting did not round-trip.")
		quit(1)
		return
	if not is_equal_approx(float(loaded.get("effects_percent", 0.0)), 68.0):
		push_error("Effects setting did not round-trip.")
		quit(1)
		return
	if not is_equal_approx(float(loaded.get("ui_scale", 1.0)), 1.25):
		push_error("UI scale setting did not round-trip.")
		quit(1)
		return
	if not bool(loaded.get("high_contrast", false)):
		push_error("High-contrast setting did not round-trip.")
		quit(1)
		return
	if int(loaded.get("starting_opponent_tier", -1)) != 2:
		push_error("Starting opponent selection did not round-trip.")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("Audio and accessibility settings persistence passed.")
	quit()
