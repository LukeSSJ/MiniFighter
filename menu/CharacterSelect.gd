extends Control

onready var p2_selection := $Characters/CharacterSelection2

var player_count := 2
var players_ready := 0

func _ready():
	if Global.single_player:
		player_count = 1
		p2_selection.queue_free()

func player_selected(player_index, character):
	Global.player_character[player_index] = character
	
	players_ready += 1
	if players_ready == player_count:
		get_tree().change_scene("res://Main.tscn")

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://menu/Menu.tscn")
