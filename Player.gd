extends KinematicBody2D

signal knocked_out
signal take_damage
signal set_combo_count

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

const WALL_LEFT_X = 20
const WALL_RIGHT_X = 1024 - 20

export var WALK_SPEED = 400
export var JUMP_VEL = Vector2(300, -1600)
export var GRAVITY = 20

var active = false
var index
var controller
var other_player
var on_ground = true
var gravity_enabled = true
var friction_enabled = true
var hp = 100
var invul_hit = false
var invul_projectile = false
var vel = Vector2.ZERO
var half_width
var action = "Stand"
var facing
var state = State.FREE
var pose = Pose.STAND
var hitstop = false
var in_blockstun = false
var knockdown = false
var air_action = false
var attack_hit = false
var grab_point = false
var normal = {
	"A": ["JA", "5A", "2A"],
	"B": ["JB", "5B", "2B"],
	"C": ["JC", "5C", "2C"],
}
var combo_count = 0
var combo_damage = 0

func _ready():
	half_width = $Collision.shape.extents.x
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
	for i in get_slide_count():
		var col = get_slide_collision(i).collider
		if col is KinematicBody2D and !on_ground:
			if position.x < other_player.position.x:
				position.x = other_player.position.x - half_width - other_player.half_width - 1
				if position.x < WALL_LEFT_X:
					other_player.position.x += WALL_LEFT_X - position.x
					position.x = WALL_LEFT_X
			else:
				position.x = other_player.position.x + half_width + other_player.half_width + 1
				if position.x > WALL_RIGHT_X:
					other_player.position.x -= position.x - WALL_RIGHT_X
					position.x = WALL_RIGHT_X
	position.x = clamp(position.x, WALL_LEFT_X, WALL_RIGHT_X)
	
	on_ground = position.y >= 0
	if on_ground:
		position.y = 0
		if friction_enabled:
			vel.x = lerp(vel.x, 0, 0.3)
		if vel.y > 0:
			if state == State.HITSTUN and knockdown:
				perform_action("Knockdown")
				invul_on()
				$TimerStun.stop()
			elif air_action:
				perform_action("Stand")

func attempt_all_actions():
	if controller.button.a and controller.button.b:
		attempt_action("Grab")
	if controller.button.d:
		if controller.dir.y == 1:
			attempt_action("SpinKick")
		elif controller.dir == Vector2.RIGHT:
			attempt_action("Uppercut")
		else:
			attempt_action("Fireball")
	if controller.button.c:
		attempt_normal("C")
	if controller.button.b:
		attempt_normal("B")
	if controller.button.a:
		attempt_normal("A")
	if state != State.FREE:
		return
	if on_ground: # Ground actions
		if controller.dir.y == -1:
				perform_action("Jump")
		elif controller.dir.y == 1:
			pose = Pose.CROUCH
			if action != "Crouch":
				perform_action("Crouch")
		else:
			pose = Pose.STAND
			if action != "Stand":
				perform_action("Stand")
			if controller.dir.x != 0:
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
	gravity_enabled = true
	friction_enabled = true
	knockdown = false
	attack_hit = false
	if on_ground:
		vel.x = 0
		air_action = false
	else:
		air_action = true
	if new_action in ["Stand", "Crouch", "Air"]:
		state = State.FREE
		in_blockstun = false
		combo_count = 0
		combo_damage = 0
		emit_signal("set_combo_count", self)
	else:
		state = State.ATTACK
	var old = $Pivot.get_node(action)
	old.hide()
	for child in old.get_children():
		if child is Area2D:
			for col in child.get_children():
				col.set_deferred("disabled", true)
	invul_off()
	action = new_action
	$Pivot.get_node(new_action).show()
	$Actions.stop()
	$Actions.play(new_action)

func on_hit(hitbox):
	if !active:
		return
	if (invul_hit and !hitbox.is_projectile) or (invul_projectile and hitbox.is_projectile):
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
			Global.Guard.UNBLOCKABLE:
				if !on_ground:
					return
	var damage = hitbox.damage 
	if blocked:
		if controller.dir.y == 1:
			perform_action("CrouchBlock")
		else:
			perform_action("Block")
		in_blockstun = true
		damage *= hitbox.chip_mod
		vel.x = hitbox.pushback * hitbox.player.facing
	else:
		perform_action("Hitstun")
		if !on_ground:
			vel = hitbox.juggle
			vel.x *= hitbox.owner.facing
			knockdown = true
		if hitbox.launch:
			vel = hitbox.launch
			vel.x *= hitbox.owner.facing
			knockdown = true
		else:
			vel.x = hitbox.pushback * hitbox.player.facing
	if combo_count > 0:
		damage *= 0.5
	combo_count += 1
	combo_damage += damage
	emit_signal("set_combo_count", self)
	hp -= damage
	state = State.HITSTUN
	$TimerStun.wait_time = hitbox.hitstun
	$TimerStun.start()
	emit_signal("take_damage", index, hp)
	if hp <= 0:
		emit_signal("knocked_out")
	add_hitstop(0.1)
	if hitbox.owner:
		hitbox.owner.add_hitstop(0.1)
		hitbox.owner.attack_hit = true
	else:
		hitbox.queue_free()
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
	perform_action("Stand")

func action_end(_anim_name):
	perform_action("Stand")

func jump():
	vel = JUMP_VEL
	vel.x *= controller.dir.x * facing

func invul_on():
	invul_hit = true
	invul_projectile = true

func invul_projectile_on():
	invul_projectile = true

func invul_off():
	invul_hit = false
	invul_projectile = false

func set_grabbed(grabbed):
	$Collision.disabled = grabbed
	gravity_enabled = !grabbed
