extends "res://Hitbox.gd"

export var speed = 600

var vel

func _ready():
	is_projectile = true
	vel = speed * facing
	scale.x = facing

func _process(delta):
	position.x += vel * delta

func off_screen():
	queue_free()
