extends Area2D

export var damage = 10
export var chip_mod = 0.2
export var pushback = 300
export var launch = Vector2.ZERO
export var juggle = Vector2(100, -800)
export var hitstun = 0.4
export var blockstun_mod = 1.0
export var hitstop = 0.1
export (Global.Guard) var guard = Global.Guard.MID
export var on_hit_action = ""
export var cancel_to = ""
export var hit_sfx = "Hit"
export var pitch_mod = 1.0

var player
var facing
var hits = 1

var is_projectile = false

func _ready():
	if !player:
		player = get_parent().owner
	if player.index == 0:
		set_collision_mask_bit(1, true)
	else:
		set_collision_mask_bit(2, true)

func on_hit():
	pass
