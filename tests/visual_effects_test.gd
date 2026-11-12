extends SceneTree

const VisualEffects = preload("res://scripts/visual_effects.gd")

func _initialize() -> void:
	var win := VisualEffects.flash_color("win")
	var loss := VisualEffects.flash_color("lose")
	var push := VisualEffects.flash_color("push")
	if win.g <= win.r or win.r <= win.b:
		push_error("Win flash should use a green-gold color.")
		quit(1)
		return
	if loss.r <= loss.g or loss.r <= loss.b:
		push_error("Loss flash should use a warning red.")
		quit(1)
		return
	if push.b <= push.r or push.b <= push.g:
		push_error("Push flash should use a distinct violet.")
		quit(1)
		return
	if VisualEffects.camera_shake_strength("lose") <= 0.0 or VisualEffects.camera_shake_strength("win") != 0.0:
		push_error("Camera shake should only be applied to losses.")
		quit(1)
		return
	print("Outcome lighting and camera feedback tests passed.")
	quit()
