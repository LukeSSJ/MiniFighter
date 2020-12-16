extends KinematicBody2D

signal knocked_out
signal take_damage

enum State {
	FREE,
	ATTACK,
	HITSTUN,
}
enum Pose {
	STAND,
	CROUCH,
	AIR,
}

export var WALK_SPEED = 400
export var JUMP_VEL = Vector2(300, -1600)
export var GRAVITY = 20

var active
var index
var controller
var other_player
var on_ground
var hp
var vel
var action
var facing
var state
var pose
var in_blockstun
var air_action
var move_hit

func _ready():
	active = false
	hp = 100
	on_ground = true
	state = State.FREE
	pose = Pose.STAND
	vel = Vector2.ZERO
	position.y -= $Collision.shape.extents.y / 2 - 1
	move_and_slide(Vector2(1,0), Vector2.UP)
	action = "Stand"
	move_hit = false
	perform_action("Stand")

func set_index(set_index):
	index = set_index
	controller.set_index(index)
	if index == 0:
		facing = 1
	else:
		facing = -1
		$Pivot.scale.x = -1

func _process(_delta):
	controller.update()
	controller.dir.x *= facing
	if on_ground:
		if air_action:
			perform_action("Stand")
		if state != State.FREE or !active:
			pass
		elif controller.button.a:
			if controller.button.b:
				perform_action("Grab")
			elif controller.dir.y == 1:
				perform_action("CrouchKick")
			else:
				perform_action("Jab")
		elif controller.dir.y == -1:
			perform_action("Jump")
		elif controller.dir.y == 1:
			if action != "Crouch":
				perform_action("Crouch")
		else:
			if action != "Stand":
				perform_action("Stand")
			vel.x = controller.dir.x * facing * WALK_SPEED
			if facing == 1:
				if other_player.position.x < position.x:
					facing = -1
					$Pivot.scale.x = -1
			elif other_player.position.x > position.x:
					facing = 1
					$Pivot.scale.x = 1
	else:
		if state != State.FREE or !active:
			pass
		elif controller.button.a:
			perform_action("JumpKick")
		elif action != "Air":
			perform_action("Air")
		vel.y += GRAVITY
	move_and_slide(vel, Vector2.UP)
	on_ground = is_on_floor()

func perform_action(new_action):
	if on_ground:
		vel.x = 0
		air_action = false
	else:
		air_action = true
	if new_action in ["Stand", "Crouch", "Air"]:
		state = State.FREE
	else:
		state = State.ATTACK
	var old = $Pivot.get_node(action)
	old.hide()
	for child in old.get_children():
		if child is Area2D:
			for col in child.get_children():
				col.set_deferred("disabled", true)
	$Pivot.get_node(new_action).show()
	$Actions.play(new_action)
	action = new_action

func on_hit(hitbox):
	if !active:
		return
	var blocked = false
	if (state == State.FREE or in_blockstun) and controller.dir.x == -1:
		match hitbox.guard:
			Global.Guard.MID:
				blocked = true
			Global.Guard.LOW:
				blocked = (controller.dir.y == 1)
			Global.guard.HIGH:
				blocked = (controller.dir.y == 0)
	if blocked:
		if controller.dir.y == 1:
			perform_action("CrouchBlock")
		else:
			perform_action("Block")
		in_blockstun = true
		hp -= hitbox.damage * hitbox.chip_mod
	else:
		perform_action("Hitstun")
		hp -= hitbox.damage
	state = State.HITSTUN
	$TimerStun.wait_time = hitbox.hitstun
	$TimerStun.start()
	vel = Vector2(hitbox.pushback * hitbox.player.facing, 0)
	emit_signal("take_damage", index, hp)
	if hp <= 0:
		emit_signal("knocked_out")

func stun_end():
	in_blockstun = false
	perform_action("Stand")

func action_end(_anim_name):
	perform_action("Stand")

func jump():
	vel = JUMP_VEL
	vel.x *= controller.dir.x * facing
