extends Node2D

func start():
	$Sprite.frame = 0

func performing(_delta):
	if owner.vel.y > 250:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
