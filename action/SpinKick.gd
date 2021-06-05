extends "res://action/Mover.gd"

var follow_up_count

func start():
	follow_up_count = 0
	$Hitbox.juggle.y = -1400

func first_kick():
	owner.vel.x = owner.facing * 600
	if owner.on_ground:
		owner.vel.y = -1000
		owner.pose = owner.Pose.AIR
	owner.friction_enabled = false

func check_follow_up():
	if owner.controller.button.d_held and follow_up_count < 2:
		if owner.consume_special(5):
			$Hitbox.juggle.y = -400
			owner.get_node("Actions").seek(0.1)
			owner.vel.y = -800
			follow_up_count += 1
