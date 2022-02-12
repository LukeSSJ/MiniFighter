extends Node2D

export (PackedScene) var Projectile

func throw_fireball():
	var projectile = Projectile.instance()
	projectile.player = owner
	projectile.facing = owner.facing
	projectile.position = $Point.global_position
	projectile.hits = 1
	get_tree().current_scene.add_child(projectile)
