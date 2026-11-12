class_name SurvivalAccessibilityLayout
extends RefCounted

static func fit_scale(viewport_size: Vector2, panel_size: Vector2, margin: float = 24.0) -> float:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return 1.0
	var width_scale := (viewport_size.x - margin) / panel_size.x
	var height_scale := (viewport_size.y - margin) / panel_size.y
	return clampf(minf(1.0, minf(width_scale, height_scale)), 0.5, 1.0)
