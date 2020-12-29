extends Node2D

var dir = Vector2.ZERO
var player

var input = {
	"left": "",
	"right": "",
	"up": "",
	"down": "",
	"a": "",
	"b": "",
	"c": "",
	"d": "",
}
var button = {
	"a": false,
	"b": false,
	"c": false,
	"d": false,
	"d_held": false,
}
var button_timer = {}

func set_index(index, set_player):
	player = set_player
	var prefix
	if index == 0:
		prefix = "p1_"
	else:
		prefix = "p2_"
	for i in input:
		input[i] = prefix + i
	for b in ["a", "b", "c", "d"]:
		var timer = Timer.new()
		timer.wait_time = 0.1
		timer.one_shot = true
		timer.connect("timeout", self, "depress_button", [b])
		add_child(timer)
		button_timer[b] = timer

func update():
	dir = Vector2.ZERO
	if Input.is_action_pressed(input.left):
		dir.x -= 1
	if Input.is_action_pressed(input.right):
		dir.x += 1
	if Input.is_action_pressed(input.up):
		dir.y -= 1
	if Input.is_action_pressed(input.down):
		dir.y += 1
	
	if Input.is_action_just_pressed(input.a):
		button.a = true
		button_timer.a.start()
	if Input.is_action_just_pressed(input.b):
		button.b = true
		button_timer.b.start()
	if Input.is_action_just_pressed(input.c):
		button.c = true
		button_timer.c.start()
	if Input.is_action_just_pressed(input.d):
		button.d = true
		button_timer.d.start()
#	button.a = Input.is_action_just_pressed(input.a)
#	button.b = Input.is_action_just_pressed(input.b)
#	button.c = Input.is_action_just_pressed(input.c)
#	button.d = Input.is_action_just_pressed(input.d)
	button.d_held = Input.is_action_pressed(input.d)

func depress_button(button_key):
	button[button_key] = false

func on_attack_hit():
	pass
