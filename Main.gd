extends Node2D

var players = [null, null]
var wins
var round_count
var round_is_over
var time_left
var time_up

onready var Player = preload("res://character/EyePatch.tscn")
onready var Controller = preload("res://controller/Controller.tscn")
onready var ControllerCPU = preload("res://controller/ControllerCPU.tscn")
onready var ControllerDummy = preload("res://controller/ControllerDummy.tscn")
onready var UI = $UI

func _ready():
	UI.connect("rematch", self, "game_start")
	game_start()
	if Global.music:
		$Music.play()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene("res://menu/Menu.tscn")

func game_start():
	round_count = 1
	wins = [0, 0]
	round_start()

func round_start():
	if players[0]:
		players[0].queue_free()
		players[1].queue_free()
	
	for i in 2:
		var player = Player.instance()
		players[i] = player
		
		var ControllerType = Controller
		if Global.game_mode == Global.VS_CPU and i == 1:
			ControllerType = ControllerCPU
		elif Global.input_methods[i] == null:
			ControllerType = ControllerDummy
		var controller = ControllerType.instance()
		
		player.controller = controller
		player.add_child(controller)
		player.set_index(i)
		player.position = Vector2(400, 580)
		if i == 1:
			player.position.x = 1024 - 400
		
		player.connect("take_damage", UI, "update_hp")
		player.connect("update_special", UI, "update_special")
		player.connect("set_combo_count", UI, "set_combo_count")
		player.connect("knocked_out", self, "knocked_out")
		
		$Floor.add_child(player)
		
		UI.update_hp(i, player.hp)
		UI.update_special(i, player.special)
		UI.set_combo_count(player)
		UI.set_wins(i, wins[i])
	
	players[0].other_player = players[1]
	players[1].other_player = players[0]
	
	players[1].set_color(Color8(255, 0, 0))
	
	round_is_over = false
	time_left = 60
	time_up = false
	
	if Global.game_mode == Global.TRAINING:
		fight()
	else:
		$TimerRoundStart.start()
		UI.round_start(round_count)
		UI.update_timer(time_left)

func fight():
	players[0].active = true
	players[1].active = true
	if Global.game_mode != Global.TRAINING:
		$TimerRound.start()

func timer_count_down():
	time_left -= 1
	UI.update_timer(time_left)
	if time_left == 0:
		time_up = true
		players[0].active = false
		players[1].active = false
		UI.time_up()
		round_over()

func knocked_out():
	UI.KO()
	round_over()

func round_over():
	if round_is_over:
		return
	round_is_over = true
	players[0].active = false
	players[1].active = false
	$TimerRound.stop()
	$TimerNextRound.start()

func next_round():
	var text = "KO"
	var winner = -1
	
	if players[0].hp <= 0:
		if players[1].hp <= 0:
			text = "Double KO"
		else:
			winner = 1
	elif players[1].hp <= 0:
		winner = 0
	elif players[0].hp > players[1].hp:
		winner = 0
	elif players[1].hp > players[0].hp:
		winner = 1
	else:
		text = "Draw"
	
	round_count += 1
	if winner != -1:
		wins[winner] += 1
		UI.set_wins(winner, wins[winner])
		if wins[winner] >= 2:
			text = "Player %d Wins" % (winner + 1)
			UI.round_is_over = true
			UI.show_result(text)
			return
	UI.show_result(text)
	round_start()
