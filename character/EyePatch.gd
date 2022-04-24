extends "res://character/Character.gd"

func attempt_character_actions():
	
	# Specials
	if controller.button.d and (state == State.FREE or can_special_cancel):
		if controller.dir.x == 1:
			if controller.dir.y == 1:
				attempt_action("Knee", 25)
			else:
				attempt_action("Uppercut", 25)
		elif controller.dir.y == 1 and on_ground:
			attempt_action("FireballLow", 20)
		else:
			attempt_action("FireballHigh", 20)
	
	# Command normals
	if controller.button.c and controller.dir.x == 1:
		attempt_action("6C")
	if controller.button.a and controller.dir.x == 1:
		attempt_action("6A")
