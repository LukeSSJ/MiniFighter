extends Area2D

export var damage = 10
export var chip_mod = 0.2
export var pushback = 50
export var hitstun = 0.4
export (Global.Guard) var guard = Global.Guard.MID

var player

func _ready():
	player = get_parent().owner
	if player.index == 0:
		set_collision_mask_bit(1, true)
	else:
		set_collision_mask_bit(2, true)
