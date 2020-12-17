extends Node2D

func grab():
	owner.grab_point = $Point
	owner.other_player.set_grabbed(true)

func release():
	owner.grab_point = null
	owner.other_player.set_grabbed(false)
