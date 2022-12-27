extends TextureRect

signal selected

export var player_index := 0

var index := 0
var has_selected := false

onready var grid := get_node("../Grid")

func _input(_event):
	if has_selected:
		return
	if Input.is_action_just_pressed("ui_left") and index > 0:
		index -= 1
		update_position()
	elif Input.is_action_just_pressed("ui_right") and index < grid.get_child_count() - 1:
		index += 1
		update_position()
	elif Input.is_action_just_pressed("ui_accept"):
		has_selected = true
		emit_signal("selected", player_index, grid.get_child(index).character_name)

func update_position():
	rect_position = grid.get_child(index).rect_position
