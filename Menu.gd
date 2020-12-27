extends CanvasLayer

onready var VsPlayer = $Buttons/List/VsPlayer
onready var VsCPU = $Buttons/List/VsCPU
onready var Training = $Buttons/List/Training

func _ready():
	VsPlayer.connect("pressed", self, "vs_player")
	VsCPU.connect("pressed", self, "vs_cpu")
	Training.connect("pressed", self, "training")
	VsPlayer.grab_focus()

func vs_player():
	Global.game_mode = Global.VS_PLAYER
	get_tree().change_scene("res://Main.tscn")

func vs_cpu():
	Global.game_mode = Global.VS_CPU
	get_tree().change_scene("res://Main.tscn")

func training():
	Global.game_mode = Global.TRAINING
	get_tree().change_scene("res://Main.tscn")
