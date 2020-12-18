extends Node2D

export (PackedScene) var Projectile

func throw_fireball():
	var projectile = Projectile.instance()
	projectile.player = owner
	projectile.position = $Point.global_position
	projectile.scale.x = owner.facing
	owner.get_parent().add_child(projectile)
