extends "res://Hitbox.gd"

export var speed = 600

var vel
var in_hitstop = false

func _ready():
	is_projectile = true
	vel = speed * facing
	scale.x = facing

func _process(delta):
	if !in_hitstop:
		position.x += vel * delta

func on_hit():
	hits -= 1
	if hits == 0:
		queue_free()
	else:
		in_hitstop = true
		$TimerHitstop.wait_time = hitstop
		$TimerHitstop.start()
		$CollisionShape2D.set_deferred("disabled", true)

func off_screen():
	queue_free()

func hitstop_end():
	in_hitstop = false
	$CollisionShape2D.set_deferred("disabled", false)
