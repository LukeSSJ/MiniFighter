extends "res://Controller.gd"

func update():
	dir = Vector2.ZERO
	dir.x *= player.facing
