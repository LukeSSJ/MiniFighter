extends CanvasLayer

onready var VsPlayer = $Main/Buttons/List/VsPlayer
onready var VsCPU = $Main/Buttons/List/VsCPU
onready var Training = $Main/Buttons/List/Training
onready var Trials = $Main/Buttons/List/Trials
#onready var Online = $Main/Buttons/List/Online
onready var Music = $Main/Options/Music
onready var ChooseInput = $ChooseInput

func _ready():
	VsPlayer.connect("pressed", self, "vs_player")
	VsCPU.connect("pressed", self, "vs_cpu")
	Training.connect("pressed", self, "training")
	Trials.connect("pressed", self, "trials")
#	Online.connect("pressed", self, "online")
	
	Music.connect("toggled", self, "toggle_music")
	Music.pressed = Global.music
	
	ChooseInput.connect("input_choosen", self, "input_choosen")
	ChooseInput.connect("cancel", self, "input_choosen_cancelled")
	
	VsPlayer.grab_focus()

func vs_player():
	Global.game_mode = Global.VS_PLAYER
	Global.single_player = false
	$Main.hide()
	ChooseInput.choose(true)

func vs_cpu():
	Global.game_mode = Global.VS_CPU
	Global.single_player = true
	clear_inputs("p1_")
	map_inputs("p1_", 0) # Keyboard
	map_inputs("p1_", 1) # Controller 1
	get_tree().change_scene("res://Main.tscn")

func training():
	Global.game_mode = Global.TRAINING
	Global.single_player = true
	$Main.hide()
	ChooseInput.choose(false)

func trials():
	Global.game_mode = Global.TRIALS
	Global.single_player = true
	$Main.hide()
	ChooseInput.choose(false)

func online():
	Global.game_mode = Global.ONLINE
	Global.single_player = true
	get_tree().change_scene("res://menu/MenuOnline.tscn")

func toggle_music(on):
	Global.music = on

func input_choosen(players):
	Global.input_methods = players
	clear_inputs("p1_")
	if players[0] != null:
		map_inputs("p1_", players[0])
	else:
		map_inputs("p1_", players[1] + 1)
	clear_inputs("p2_")
	if players[1] != null:
		map_inputs("p2_", players[1])
	else:
		map_inputs("p2_", players[0] + 1)
	get_tree().change_scene("res://Main.tscn")

func input_choosen_cancelled():
	$Main.show()
	VsPlayer.grab_focus()

func clear_inputs(prefix):
	InputMap.action_erase_events(prefix + "left")
	InputMap.action_erase_events(prefix + "right")
	InputMap.action_erase_events(prefix + "up")
	InputMap.action_erase_events(prefix + "down")
	InputMap.action_erase_events(prefix + "a")
	InputMap.action_erase_events(prefix + "b")
	InputMap.action_erase_events(prefix + "c")
	InputMap.action_erase_events(prefix + "d")
	InputMap.action_erase_events(prefix + "ab")

func map_inputs(prefix, input_method):
	InputMap.action_add_event(prefix + "left", create_input(input_method, KEY_A, JOY_DPAD_LEFT))
	InputMap.action_add_event(prefix + "right", create_input(input_method, KEY_D, JOY_DPAD_RIGHT))
	InputMap.action_add_event(prefix + "up", create_input(input_method, KEY_W, JOY_DPAD_UP))
	InputMap.action_add_event(prefix + "down", create_input(input_method, KEY_S, JOY_DPAD_DOWN))
	InputMap.action_add_event(prefix + "a", create_input(input_method, KEY_J, JOY_SONY_SQUARE))
	InputMap.action_add_event(prefix + "b", create_input(input_method, KEY_K, JOY_SONY_TRIANGLE))
	InputMap.action_add_event(prefix + "c", create_input(input_method, KEY_L, JOY_SONY_CIRCLE))
	InputMap.action_add_event(prefix + "d", create_input(input_method, KEY_SEMICOLON, JOY_SONY_X))
	InputMap.action_add_event(prefix + "ab", create_input(input_method, KEY_I, JOY_R))
	if input_method == 0:
		InputMap.action_add_event(prefix + "up", create_input(input_method, KEY_Z))
		InputMap.action_add_event(prefix + "left", create_input(input_method, KEY_Q))

func create_input(input_method, key, button=null):
	var event
	if input_method == 0:
		event = InputEventKey.new()
		event.scancode = key
	else:
		event = InputEventJoypadButton.new()
		event.button_index = button
	return event
