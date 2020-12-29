extends "res://Controller.gd"

var next_button

func update():
	button.a = false
	button.b = false
	button.c = false
	button.d = false
	dir.x = 0
	dir.y = 0
	var distance = abs(player.position.x - player.other_player.position.x)
#	if distance < 60:
#		button.a = true
#		button.b = true
#	elif distance < 80:
#		button.a = true
#	elif distance < 120:
#		button.b = true
#	elif distance < 170:
#		button.c = true
#	else:
#		button.d = true
	if next_button and !player.hitstop:
		button[next_button] = true
		next_button = null
	if distance < 80:
		next_button = "d"
		dir.x = 1
	else:
		dir.x = 1
	dir.x *= player.facing

#func on_attack_hit():
#	match player.action:
#		"2A", "5A":
#			next_button = "b"
#		"5B":
#			next_button = "c"
