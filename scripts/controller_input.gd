class_name SurvivalControllerInput
extends RefCounted

static func action_for_button(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_A:
			return "hit"
		JOY_BUTTON_B:
			return "stand"
		JOY_BUTTON_X:
			return "double"
		JOY_BUTTON_Y:
			return "next_hand"
		JOY_BUTTON_LEFT_SHOULDER:
			return "marked_card"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "house_bell"
		JOY_BUTTON_START:
			return "restart"
	return ""
