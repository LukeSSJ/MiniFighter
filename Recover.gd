extends Node2D

func hop():
	owner.vel = Vector2(owner.controller.dir.x * owner.facing * 300, -600)
