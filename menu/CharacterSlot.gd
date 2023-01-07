extends MarginContainer

export var character_name := ""
export (Texture) var portrait

func _ready():
	$Portrait.texture = portrait
