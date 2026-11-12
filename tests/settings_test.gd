extends SceneTree

const SettingsStore = preload("res://scripts/settings_store.gd")

func _initialize() -> void:
	var path := "user://settings_test.cfg"
	var values := {"ambience_percent": 12.0, "effects_percent": 68.0}
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
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("Audio settings persistence passed.")
	quit()
