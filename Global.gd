extends Node

enum {
	VS_PLAYER,
	VS_CPU,
	TRAINING,
}

enum Guard {
	MID,
	LOW,
	HIGH
	UNBLOCKABLE,
}

var music = true

var game_mode
var input_methods = []
