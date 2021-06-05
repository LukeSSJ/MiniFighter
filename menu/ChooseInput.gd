extends Control

signal input_choosen
signal cancel

onready var List = $Controllers/List

var players
var controller_button
var requires_both_players

func _ready():
	set_process(false)

func choose(both_players):
	requires_both_players = both_players
	players = [null, null]
	controller_button = []
	for child in List.get_children():
		List.remove_child(child)
	
	var controllers = ["Keyboard"]
	for joypad in Input.get_connected_joypads():
		controllers.append(Input.get_joy_name(joypad))
	for name in controllers:
		var label = Label.new()
		label.text = "< " + name + " >"
		label.align = Label.ALIGN_CENTER
		List.add_child(label)
		controller_button.append([0, 0])
	set_process(true)
	show()

func _process(_delta):
	for i in List.get_child_count():
		var old_align = List.get_child(i).align
		var align = old_align
		if i == 0:
			if Input.is_action_just_pressed("keyboard_left"):
				align -= 1
			if Input.is_action_just_pressed("keyboard_right"):
				align += 1
		else:
			var j = i - 1
			if Input.is_joy_button_pressed(j, JOY_DPAD_LEFT):
				controller_button[j][0] += 1
			else:
				controller_button[j][0] = 0
			if controller_button[j][0] == 1:
				align -= 1
			if Input.is_joy_button_pressed(j, JOY_DPAD_RIGHT):
				controller_button[j][1] += 1
			else:
				controller_button[j][1] = 0
			if controller_button[j][1] == 1:
				align += 1
		var min_align = 0
		var max_align = 2
		if players[0] != null and players[0] != i:
			min_align = 1
		if players[1] != null and players[1] != i:
			max_align = 1
		align = clamp(align, min_align, max_align)
		if align == 0:
			players[0] = i
		elif align == 2:
			players[1] = i
		elif old_align == 0:
			players[0] = null
		elif old_align == 2:
			players[1] = null
		List.get_child(i).align = align
	
	if Input.is_action_just_pressed("ui_accept"):
		#if (players[0] != null and players[1] != null) or (!requires_both_players and (players[0] != null or players[1] != null)):
		if players[0] != null or players[1] != null:
			emit_signal("input_choosen", players)
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause"):
		emit_signal("cancel")
		set_process(false)
		hide()
