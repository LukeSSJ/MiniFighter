extends Area2D

func _ready():
	var player = get_parent().owner
	connect("area_entered", player, "on_hit")
	if player.index == 0:
		set_collision_layer_bit(2, true)
	else:
		set_collision_layer_bit(1, true)
