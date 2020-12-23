extends Area2D

export var damage = 10
export var chip_mod = 0.2
export var pushback = 300
export var launch = Vector2.ZERO
export var juggle = Vector2(100, -800)
export var hitstun = 0.4
export (Global.Guard) var guard = Global.Guard.MID
export var on_hit_action = ""

var player
var facing

var is_projectile = false

func _ready():
	if !player:
		player = get_parent().owner
	if player.index == 0:
		set_collision_mask_bit(1, true)
	else:
		set_collision_mask_bit(2, true)
