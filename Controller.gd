extends Node2D

var dir = Vector2.ZERO

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

func set_index(index):
	var prefix
	if index == 0:
		prefix = "p1_"
	else:
		prefix = "p2_"
	for i in input:
		input[i] = prefix + i

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
	button.a = Input.is_action_just_pressed(input.a)
	button.b = Input.is_action_just_pressed(input.b)
	button.c = Input.is_action_just_pressed(input.c)
	button.d = Input.is_action_just_pressed(input.d)
	button.d_held = Input.is_action_pressed(input.d)
