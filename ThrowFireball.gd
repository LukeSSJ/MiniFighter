extends Node2D

export (PackedScene) var Projectile

func throw_fireball():
	var projectile = Projectile.instance()
	projectile.player = owner
	projectile.position = $Point.global_position
	projectile.scale.x = owner.facing
	get_tree().current_scene.add_child(projectile)
