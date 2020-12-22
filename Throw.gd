extends Node2D

func grab():
	owner.grab_point = $Point
	if owner.controller.dir.x == -1:
		owner.other_player.set_facing(owner.facing)
		owner.set_facing(owner.facing * -1)
	owner.other_player.set_grabbed(true)

func release():
	owner.grab_point = null
	owner.other_player.set_grabbed(false)
