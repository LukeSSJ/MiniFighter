extends Node2D

export var run_speed = 200
export var jump_speed = 1400

func run():
	owner.vel.x = run_speed * owner.facing
	
func jump():
	owner.vel.y = -jump_speed

func stop():
	owner.vel = Vector2.ZERO

func run_friction_off():
	owner.vel.x = run_speed * owner.facing
	owner.friction_enabled = false

func friction_on():
	owner.friction_enabled = true
