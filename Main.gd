extends Node2D

var p = [null, null]
var wins
var round_count
var round_is_over
var time_left
var time_up

onready var Player = preload("res://character/Character.tscn")
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
	if p[0]:
		p[0].queue_free()
		p[1].queue_free()
	for i in range(0, 2):
		p[i] = Player.instance()
		var ControllerType = Controller
		if Global.game_mode == Global.VS_CPU and i == 1:
			ControllerType = ControllerCPU
		elif Global.input_methods[i] == null:
			ControllerType = ControllerDummy
		var controller = ControllerType.instance()
		p[i].controller = controller
		p[i].add_child(controller)
		p[i].set_index(i)
		p[i].position = Vector2(400, 580)
		if i == 1:
			p[i].position.x = 1024 - 400
		p[i].connect("take_damage", UI, "update_hp")
		p[i].connect("update_special", UI, "update_special")
		p[i].connect("set_combo_count", UI, "set_combo_count")
		p[i].connect("knocked_out", self, "knocked_out")
		$Floor.add_child(p[i])
		UI.update_hp(i, p[i].hp)
		UI.update_special(i, p[i].special)
		UI.set_combo_count(p[i])
		UI.set_wins(i, wins[i])
	p[0].other_player = p[1]
	p[1].other_player = p[0]
	p[1].set_color(Color8(255, 0, 0))
	$TimerRoundStart.start()
	round_is_over = false
	time_left = 60
	time_up = false
	UI.round_start(round_count)
	UI.update_timer(time_left)

func fight():
	p[0].active = true
	p[1].active = true
	if Global.game_mode != Global.TRAINING:
		$TimerRound.start()

func timer_count_down():
	time_left -= 1
	UI.update_timer(time_left)
	if time_left == 0:
		time_up = true
		p[0].active = false
		p[1].active = false
		UI.time_up()
		round_over()

func knocked_out():
	UI.KO()
	round_over()

func round_over():
	if round_is_over:
		return
	round_is_over = true
	p[0].active = false
	p[1].active = false
	$TimerRound.stop()
	$TimerNextRound.start()

func next_round():
	var text = "KO"
	var winner = -1
	if p[0].hp <= 0:
		if p[1].hp <= 0:
			text = "Double KO"
		else:
			winner = 1
	elif p[1].hp <= 0:
		winner = 0
	elif p[0].hp > p[1].hp:
		winner = 0
	elif p[1].hp > p[0].hp:
		winner = 1
	else:
		text = "Draw"
	round_count += 1
	if winner != -1:
		wins[winner] += 1
		UI.set_wins(winner, wins[winner])
		if wins[winner] >= 2:
			text = "Player " + str(winner + 1) + " Wins"
			$UI.round_is_over = true
			$UI.show_result(text)
			return
	$UI.show_result(text)
	round_start()
