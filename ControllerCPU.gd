extends "res://Controller.gd"


func update():
	button.a = false
	button.b = false
	button.c = false
	button.d = false
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
	if distance < 80:
		button.a = true
	else:
		dir.x = 1
	dir.x *= player.facing

func on_attack_hit():
	match player.action:
		"2A", "5A":
			button.b = true
