extends CanvasLayer

onready var Play = $MarginContainer/Play

var Online = {}

func _ready():
	Online.connect("game_start", self, "game_start")
	Play.connect("pressed", self, "play")
	Play.grab_focus()
	
#	play()

func play():
	Play.disabled = true
	yield(get_tree(), "idle_frame")
	
	Online.Address = "127.0.0.1"
	Online.InputDelay = 1
	Online.Rollback = 4
	Online.DupSendRange = 16
	Online.Port = 5678
	
	Online.IsLocal = false
	Online.IsPlayerOne = false
	
#	Online.IsLocal = true
#	Online.IsPlayerOne = true
#	var arg = OS.get_cmdline_args()
#	if len(arg) > 0 and arg[0] == "1":
#		print("player 2")
#		Online.IsPlayerOne = false
	
	Online.start()
	Online.Status = Online.StatusType.WAITING

func game_start():
	get_tree().change_scene("res://Main.tscn")
