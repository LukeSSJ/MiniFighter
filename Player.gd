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

var active = false
var index
var controller
var other_player
var on_ground = true
var gravity_enabled = true
var hp = 100
var vel = Vector2.ZERO
var action = "Stand"
var facing
var state = State.FREE
var pose = Pose.STAND
var hitstop = false
var in_blockstun = false
var air_action = false
var attack_hit = false
var grab_point = false
var normal = {
	"A": ["JA", "5A", "2A"],
	"B": ["JB", "5B", "2B"],
	"C": ["JC", "5C", "2C"],
}

func _ready():
	position.y -= $Collision.shape.extents.y / 2 - 1
	move_and_slide(Vector2(1,0), Vector2.UP)
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
	if hitstop:
		return
	
	if (state == State.FREE or state == State.ATTACK) and active:
		attempt_all_actions()
	if grab_point:
		other_player.position = grab_point.global_position
	if !on_ground and gravity_enabled:
		vel.y += GRAVITY
	move_and_slide(vel, Vector2.UP)
	on_ground = is_on_floor()
	if air_action and on_ground:
		perform_action("Stand")

func attempt_all_actions():
	if controller.button.a and controller.button.b:
		attempt_action("Grab")
	if controller.button.c:
		attempt_normal("C")
	if controller.button.b:
		attempt_normal("B")
	if controller.button.a:
		attempt_normal("A")
	if state != State.FREE:
		return
	if on_ground: # Ground actions
		if controller.dir.y == 1:
			pose = Pose.CROUCH
			if action != "Crouch":
				perform_action("Crouch")
		else:
			pose = Pose.STAND
			if controller.dir.y == -1:
				perform_action("Jump")
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
	else: # Air actions
		if action != "Air":
			perform_action("Air")

func attempt_normal(attack):
	if state == State.FREE or (state == State.ATTACK and attack_hit):
		if !on_ground:
			attack = normal[attack][0]
		elif controller.dir.y == 1:
			attack = normal[attack][2]
		else:
			attack = normal[attack][1]
		perform_action(attack)

func attempt_action(attack):
	if state == State.FREE or (state == State.ATTACK and attack_hit):
		perform_action(attack)

func perform_action(new_action):
	attack_hit = false
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
	$Actions.stop()
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
			Global.Guard.HIGH:
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
	add_hitstop(0.1)
	hitbox.owner.add_hitstop(0.1)
	hitbox.owner.attack_hit = true
	if hitbox.on_hit_action:
		hitbox.owner.perform_action(hitbox.on_hit_action)

func add_hitstop(time):
	hitstop = true
	$TimerHitstop.wait_time = time
	$TimerHitstop.start()
	$Actions.stop(false)
	$TimerStun.paused = true

func hitstop_end():
	hitstop = false
	$Actions.play(action)
	$TimerStun.paused = false

func stun_end():
	in_blockstun = false
	perform_action("Stand")

func action_end(_anim_name):
	perform_action("Stand")

func jump():
	vel = JUMP_VEL
	vel.x *= controller.dir.x * facing

func set_grabbed(grabbed):
	$Collision.disabled = grabbed
	gravity_enabled = !grabbed
