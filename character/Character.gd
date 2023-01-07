extends KinematicBody2D

signal knocked_out
signal take_damage
signal update_special
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
const FLOOR_Y = 580
const DOWN_FORWARD = Vector2(1, 1)

export var WALK_SPEED = 400
export var WALK_BACK_SPEED = -400
export var JUMP_VEL = Vector2(300, -1600)
export var GRAVITY = 80

var active = false
var index
var controller
var other_player
var on_ground = true
var is_grabbed = false
var friction_enabled = true
var max_hp = 100
var hp = max_hp
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
var can_recover = false
var air_action = false
var can_cancel = false
var can_special_cancel = false
var cancel_array = []
var attack_hit = false
var grab_point = false
var combo_count = 0
var combo_damage = 0
var special = 100
var special_regen = false
var Action
var normal = {
	"A": ["JA", "5A", "2A"],
	"B": ["JB", "5B", "2B"],
	"C": ["JC", "5C", "2C"],
}

var timerStun
var timerHitstop
var timerSpecialRegen

func _ready():
	timerStun = Timer.new()
	timerStun.one_shot = true
	timerHitstop = Timer.new()
	timerHitstop.one_shot = true
	timerSpecialRegen = Timer.new()
	timerSpecialRegen.one_shot = true
	timerSpecialRegen.wait_time = 0.5
	
	add_child(timerStun)
	add_child(timerHitstop)
	add_child(timerSpecialRegen)
	
	timerStun.connect("timeout", self, "stun_end")
	timerHitstop.connect("timeout", self, "hitstop_end")
	timerSpecialRegen.connect("timeout", self, "special_regen_on")
	
	$Actions.connect("animation_finished", self, "action_end")
	
	# Hide actions
	for node in $Pivot.get_children():
		node.hide()
	
	half_width = $Collision.shape.extents.x
	perform_action("Stand")
	
	if not controller:
		var Controller = preload("res://controller/Controller.tscn")
		controller = Controller.instance()
		set_index(0)

func set_index(set_index):
	index = set_index
	controller.set_index(index, self)
	if index == 0:
		facing = 1
	else:
		facing = -1
		$Pivot.scale.x = -1

func _process(delta):
	controller.update()
	process(delta)

func process(delta):
	controller.dir.x *= facing
	if hitstop or is_queued_for_deletion():
		return
	
	if special_regen:
		special = min(special + delta * 40, 100)
		emit_signal("update_special", index, special)
		if special == 100:
			special_regen = false
			
	if Action.has_method("performing"):
		Action.performing(delta)
	
	if (state == State.FREE or state == State.ATTACK) and active:
		attempt_all_actions()
	if can_recover and controller.button.a:
		perform_action("Recover")
	
	if grab_point:
		other_player.position = grab_point.global_position - Vector2(0,-120)
		if other_player.position.x < WALL_LEFT_X or other_player.position.x > WALL_RIGHT_X:
			other_player.position.x = clamp(other_player.position.x, WALL_LEFT_X, WALL_RIGHT_X)
			position.x = other_player.position.x - grab_point.position.x * facing
	
	if is_grabbed:
		return
	
	if !on_ground:
		vel.y += GRAVITY
	
	move_and_slide(vel, Vector2.UP)
	if get_slide_count() > 0:
		if !on_ground:
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
	
	on_ground = position.y >= FLOOR_Y
	if on_ground:
		position.y = FLOOR_Y
		if friction_enabled:
			vel.x = lerp(vel.x, 0, 0.25)
		if vel.y > 0:
			vel.y = 0
			if state == State.HITSTUN and knockdown:
				timerStun.stop()
				stun_end()
				perform_action("Knockdown")
				state = State.HITSTUN
				invul_on()
			elif air_action:
				perform_action("Stand")

func attempt_all_actions():
	if on_ground:
		if (controller.button.a and controller.button.b) or (controller.button.c and controller.button.d):
			attempt_action("Grab")
		if state == State.FREE:
			if facing == 1:
				if other_player.position.x < position.x:
					set_facing(-1)
			elif other_player.position.x > position.x:
					set_facing(1)
	
	attempt_character_actions()
	
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
			if action != "Crouch":
				perform_action("Crouch")
				set_pose(Pose.CROUCH)
		else:
			pose = Pose.STAND
			if action != "Stand":
				perform_action("Stand")
				set_pose(Pose.STAND)
			var animation
			if controller.dir.x == 1:
				vel.x = WALK_SPEED * facing
				animation = "walk"
			elif controller.dir.x == -1:
				vel.x = WALK_BACK_SPEED * facing
				animation = "walk_back"
			else:
				animation = "default"
			var sprite = Action.get_node("Sprite")
			if sprite.animation != animation:
				sprite.animation = animation
				sprite.frame = 0
				sprite.play()
	else: # Air actions
		if action != "Air":
			perform_action("Air")

func attempt_character_actions():
	if controller.button.d and (state == State.FREE or can_special_cancel):
		if controller.dir.y == 1:
			attempt_action("SpinKick", 25)
		elif controller.dir == Vector2.RIGHT:
			attempt_action("Uppercut", 25)
		else:
			attempt_action("Fireball", 25)
	
	if controller.dir == DOWN_FORWARD and controller.button.b:
		attempt_action("Overhead")

func attempt_normal(attack):
	if !on_ground:
		attack = normal[attack][0]
	elif controller.dir.y == 1:
		attack = normal[attack][2]
	else:
		attack = normal[attack][1]
	if state == State.FREE or (can_cancel and attack_hit and attack in cancel_array):
		perform_action(attack)
		if controller.dir.y == 1:
			set_pose(Pose.CROUCH)
		can_cancel = true
		can_special_cancel = true

func attempt_action(new_action, cost=0):
	if state == State.FREE or (can_cancel and attack_hit):
		if consume_special(cost):
			perform_action(new_action, cost)

func perform_action(new_action, cost=0):
	if not $Actions.has_animation(new_action):
		print("No action for: %s" % new_action)
		return
	
	friction_enabled = true
	knockdown = false
	can_recover = false
	can_cancel = false
	can_special_cancel = false
	cancel_array = []
	attack_hit = false
	grab_point = false
	
	if on_ground:
		air_action = false
		set_pose(Pose.STAND)
	else:
		air_action = true
		set_pose(Pose.AIR)
	
	if new_action in ["Stand", "Crouch", "Air"]:
		state = State.FREE
		# Refill health (training mode)
		if Global.game_mode == Global.TRAINING:
			hp = max_hp
			emit_signal("take_damage", index, hp)
	else:
		state = State.ATTACK
	
	if Action:
		Action.hide()
		for child in Action.get_children():
			if child is Area2D:
				for col in child.get_children():
					col.set_deferred("disabled", true)
	invul_off()
	action = new_action
	Action = $Pivot.get_node(new_action)
	Action.show()
	if Action.has_method("start"):
		Action.start()
	var sprite = Action.get_node("Sprite")
	if sprite is AnimatedSprite:
		sprite.animation = "default"
	$Pivot/Hurtbox2/HurtboxShape.set_deferred("disabled", true)
	$Actions.stop()
	$Actions.play(new_action)
	if cost == 0 and special < 100 and timerSpecialRegen.is_stopped():
		timerSpecialRegen.start()

func on_hit(hitbox):
	if !active:
		return
	if (invul_hit and !hitbox.is_projectile) or (invul_projectile and hitbox.is_projectile):
		return
	if hitbox.guard == Global.Guard.UNBLOCKABLE:
		if pose == Pose.AIR or state == State.HITSTUN:
			return
	var blocked = false
	if (state == State.FREE or in_blockstun):
		match hitbox.guard:
			Global.Guard.MID:
				blocked = (controller.dir.x == -1)
			Global.Guard.LOW:
				blocked = (controller.dir.x == -1 and controller.dir.y == 1)
			Global.Guard.HIGH:
				blocked = (controller.dir.x == -1 and controller.dir.y == 0)
	var damage = hitbox.damage
	var x_mod = hitbox.facing
	if !x_mod:
		x_mod = hitbox.owner.facing
	var apply_pushback = false
	var sfx
	if blocked:
		in_blockstun = true
		sfx = $SFX/Block
		if controller.dir.y == 1:
			perform_action("CrouchBlock")
			set_pose(Pose.CROUCH)
		else:
			perform_action("Block")
		damage *= hitbox.chip_mod
		apply_pushback = true
	else:
		in_blockstun = false
		sfx = $SFX.get_node(hitbox.hit_sfx)
		if combo_count > 0:
			damage *= 0.3
		combo_count += 1
		combo_damage += damage
		emit_signal("set_combo_count", self)
		if !on_ground or hitbox.launch:
			perform_action("AirHitstun")
		elif pose == Pose.CROUCH and apply_pushback:
			perform_action("CrouchHitstun")
			set_pose(Pose.CROUCH)
		else:
			perform_action("Hitstun")
		if !on_ground:
			vel = hitbox.juggle
			vel.x *= x_mod
			knockdown = true
		elif hitbox.launch:
			vel = hitbox.launch
			vel.x *= x_mod
			knockdown = true
		else:
			apply_pushback = true
	if apply_pushback:
		vel.x = hitbox.pushback * x_mod
	if other_player.pose != Pose.AIR and !hitbox.is_projectile:
		if abs(position.x - WALL_LEFT_X) < 5 or abs(position.x - WALL_RIGHT_X) < 5:
			other_player.vel.x = hitbox.pushback * x_mod * -1
	hp -= damage
	state = State.HITSTUN
	emit_signal("take_damage", index, hp)
	sfx.pitch_scale = hitbox.pitch_mod
	sfx.play()
	if hp <= 0:
		perform_action("KO")
		active = false
		air_action = false
		emit_signal("knocked_out")
		timerStun.stop()
	else:
		timerStun.wait_time = hitbox.hitstun
		if in_blockstun:
			timerStun.wait_time *= hitbox.blockstun_mod
		timerStun.start()
	add_hitstop(hitbox.hitstop)
	if hitbox.owner:
		hitbox.owner.add_hitstop(hitbox.hitstop)
		hitbox.owner.attack_hit = true
		hitbox.owner.cancel_array = hitbox.cancel_to.split(",", false)
		hitbox.owner.controller.on_attack_hit()
		for col in hitbox.get_children():
			col.set_deferred("disabled", true)
	hitbox.on_hit()
	if hitbox.on_hit_action:
		hitbox.owner.perform_action(hitbox.on_hit_action)

func set_pose(p):
	pose = p
	if pose == Pose.CROUCH:
		$Pivot/Hurtbox.position.y = 70
	else:
		$Pivot/Hurtbox.position.y = 0

func consume_special(cost):
	if special >= cost:
		if cost > 0:
			special -= cost
			emit_signal("update_special", index, special)
			timerSpecialRegen.stop()
			special_regen = false
		return true

func add_hitstop(time):
	hitstop = true
	timerHitstop.wait_time = time
	timerHitstop.start()
	$Actions.stop(false)
	timerStun.paused = true

func hitstop_end():
	hitstop = false
	$Actions.play(action)
	timerStun.paused = false

func stun_end():
	perform_action("Stand")
	in_blockstun = false
	combo_count = 0
	combo_damage = 0
	emit_signal("set_combo_count", self)

func action_end(_anim_name):
	perform_action("Stand")

func in_air():
	pose = Pose.AIR

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

func set_facing(f):
	facing = f
	$Pivot.scale.x = f

func set_color(c):
	var mat = material.duplicate()
	mat.set_shader_param("modulate", c)
	material = mat

func set_grabbed(grabbed):
	is_grabbed = grabbed
	$Collision.set_deferred("disabled", grabbed)

func special_regen_on():
	special_regen = true
