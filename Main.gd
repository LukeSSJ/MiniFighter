extends Node2D


var p = [null, null]
var wins
var round_count

onready var Player = preload("res://Player.tscn")
onready var Controller = preload("res://Controller.tscn")
onready var UI = $UI

func _ready():
	game_start()

func game_start():
	round_count = 1
	wins = [0, 0]
	round_start()

func round_start():
	for i in range(0, 2):
		p[i] = Player.instance()
		p[i].controller = Controller.instance()
		p[i].set_index(i)
		p[i].position = Vector2(400, 580)
		if i == 1:
			p[i].position.x = 1024 - 400
		p[i].connect("take_damage", UI, "update_hp")
		p[i].connect("update_special", UI, "update_special")
		p[i].connect("set_combo_count", UI, "set_combo_count")
		p[i].connect("knocked_out", self, "round_over")
		$Floor.add_child(p[i])
		UI.update_hp(i, 100)
		UI.set_wins(i, wins[i])
	p[0].other_player = p[1]
	p[1].other_player = p[0]
	$TimerRoundStart.start()

func fight():
	p[0].active = true
	p[1].active = true

func round_over():
	p[0].active = false
	p[1].active = false
	$TimerNextRound.start()

func next_round():
	var winner = -1
	if p[0].hp <= 0:
		if p[1].hp <= 0:
			print("double KO")
		else:
			print("player 2 wins")
			winner = 1
	elif p[1].hp <= 0:
		print("player 1 wins")
		winner = 0
	elif p[0].hp > p[1].hp:
		print("player 1 wins")
		winner = 0
	elif p[1].hp > p[0].hp:
		print("player 2 wins")
		winner = 1
	else:
		print("draw")
	p[0].queue_free()
	p[1].queue_free()
	round_count += 1
	if winner != -1:
		wins[winner] += 1
		if wins[winner] >= 2:
			print("game won")
			game_start()
			return
	round_start()
