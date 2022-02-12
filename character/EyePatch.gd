extends "res://character/Character.gd"

func attempt_character_actions():
	if controller.button.d and (state == State.FREE or can_special_cancel):
		if controller.dir.x == 1:
			attempt_action("Knee", 25)
		elif controller.dir.y == 1 and on_ground:
			attempt_action("FireballLow", 20)
		else:
			attempt_action("FireballHigh", 20)
