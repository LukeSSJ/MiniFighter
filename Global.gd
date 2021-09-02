extends Node

enum {
	VS_PLAYER,
	VS_CPU,
	TRAINING,
	TRIALS,
	ONLINE,
}

enum Guard {
	MID,
	LOW,
	HIGH,
	UNBLOCKABLE,
}

var music = false

var game_mode
var input_methods = [0, null]
