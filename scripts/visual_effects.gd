class_name SurvivalVisualEffects
extends RefCounted

static func flash_color(result: String) -> Color:
	match result:
		"win":
			return Color(0.72, 0.88, 0.42)
		"lose":
			return Color(0.95, 0.12, 0.10)
		"push":
			return Color(0.62, 0.42, 0.82)
		_:
			return Color(0.35, 0.52, 0.48)

static func camera_shake_strength(result: String) -> float:
	return 0.12 if result == "lose" else 0.0
