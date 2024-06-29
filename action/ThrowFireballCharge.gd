extends Node2D

export (PackedScene) var Projectile

var held
var hold_time
var level
var projectile
var pulse

func start():
	held = false
	hold_time = 0
	level = 1
	pulse = 0
	$Fireball.scale = Vector2(1,1)
	$TimerPulse.start()
	

func performing(delta):
	$Fireball.scale = Vector2(0.5, 0.5) * (level + pulse * 0.5 + 0.5)
	if held:
		hold_time += delta
		if level == 1 and hold_time >= 0.5:
			level = 2
		elif level == 2 and hold_time >= 1:
			level = 3
		if !owner.controller.button.d_held or hold_time >= 1.5:
			owner.get_node("Actions").play()

func check_held():
	if owner.controller.button.d_held:
		held = true
		owner.get_node("Actions").stop(false)

func throw_fireball():
	projectile = Projectile.instance()
	projectile.player = owner
	projectile.facing = owner.facing
	projectile.position = $Point.global_position
	projectile.hits = level
	get_tree().current_scene.add_child(projectile)
	$TimerPulse.stop()
	$Throw.play()

func _on_TimerPulse_timeout():
	pulse = 1 - pulse
