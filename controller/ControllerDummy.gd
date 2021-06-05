extends "res://controller/Controller.gd"

func update():
	dir = Vector2.ZERO
	dir.x *= player.facing
