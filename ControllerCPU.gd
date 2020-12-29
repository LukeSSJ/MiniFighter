extends "res://Controller.gd"

enum Plan {
	RUNUP,
	RUNUP_LIGHT,
	RUNUP_LOW_LIGHT,
	RUNUP_MED,
	RUNUP_HEAVY,
	RUNUP_LOW_HEAVY,
	RUNUP_THROW,
	FIREBALL,
	UPPERCUT,
	SPINKICK_SINGLE,
	SPINKICK_FULL,
	LIGHT,
	LOW_LIGHT,
	MED,
	HEAVY,
	LOW_HEAVY,
	ANTI_AIR,
	THROW,
	OVERHEAD,
	JUMP_LIGHT,
	JUMP_MED,
	JUMP_HEAVY,
	JUMP_EMPTY,
	BACKUP,
	BACKUP_LIGHT,
	BACKUP_LIGHT_LOW,
	BACKUP_MED,
	BACKUP_HEAVY,
	BACKUP_HEAVY_LOW,
	BACKUP_ANTI_AIR,
}

enum Action {
	RUNUP,
	BACKUP,
	JUMP,
	ATTACK,
	THROW,
	ANTI_AIR,
}

var next_button
var plans = []
var actions = []

const close_range = 200
const mid_range = 300

func update():
	button.a = false
	button.b = false
	button.c = false
	button.d = false
	dir.x = 0
	dir.y = 0
	
	var distance = abs(player.position.x - player.other_player.position.x)
	
	if next_button:
		button[next_button] = true
		next_button = null
	
	if len(actions) == 0:
		plans = []
		if distance <= close_range: # Close range
			add_plan(Plan.UPPERCUT)
			add_plan(Plan.SPINKICK_SINGLE)
			add_plan(Plan.SPINKICK_FULL)
			add_plan(Plan.LIGHT)
			add_plan(Plan.LOW_LIGHT)
			add_plan(Plan.MED)
			add_plan(Plan.HEAVY)
			add_plan(Plan.LOW_HEAVY)
			add_plan(Plan.ANTI_AIR)
			add_plan(Plan.THROW)
			add_plan(Plan.OVERHEAD)
		elif distance <= mid_range: # Midrange
			add_plan(Plan.RUNUP_THROW)
			add_plan(Plan.SPINKICK_SINGLE)
			add_plan(Plan.SPINKICK_FULL)
		if distance > close_range: # Mid and long range
			add_plan(Plan.RUNUP)
			add_plan(Plan.RUNUP_LIGHT)
			add_plan(Plan.RUNUP_LOW_LIGHT)
			add_plan(Plan.RUNUP_MED)
			add_plan(Plan.RUNUP_HEAVY)
			add_plan(Plan.RUNUP_LOW_HEAVY)
			add_plan(Plan.FIREBALL)
			add_plan(Plan.JUMP_LIGHT)
			add_plan(Plan.JUMP_MED)
			add_plan(Plan.JUMP_HEAVY)
			add_plan(Plan.JUMP_EMPTY)
			add_plan(Plan.BACKUP_LIGHT)
			add_plan(Plan.BACKUP_LIGHT_LOW)
			add_plan(Plan.BACKUP_MED)
			add_plan(Plan.BACKUP_HEAVY)
			add_plan(Plan.BACKUP_HEAVY_LOW)
			add_plan(Plan.BACKUP_ANTI_AIR)
	var plan = plans[randi() % len(plans)]
	match plan:
		Plan.RUNUP_LIGHT:
			actions.append([Action.RUNUP, 50 + rng(30)])
			actions.append([Action.ATTACK, "a", Vector2.ZERO])
		Plan.RUNUP_LOW_LIGHT:
			actions.append([Action.RUNUP, 50 + rng(30)])
			actions.append([Action.ATTACK, "a", Vector2.DOWN])
		Plan.RUNUP_MED:
			actions.append([Action.RUNUP, 120 + rng(50)])
			actions.append([Action.ATTACK, "b", Vector2.ZERO])
		Plan.RUNUP_HEAVY:
			actions.append([Action.RUNUP, 140 + rng(60)])
			actions.append([Action.ATTACK, "a", Vector2.ZERO])
		Plan.RUNUP_LOW_HEAVY:
			actions.append([Action.RUNUP, 140 + rng(60)])
			actions.append([Action.ATTACK, "a", Vector2.DOWN])
		Plan.RUNUP_THROW:
			actions.append([Action.RUNUP, 40 + rng(30)])
			actions.append([Action.THROW])
		Plan.FIREBALL:
			actions.append([Action.ATTACK, "d", Vector2.ZERO])
		Plan.UPPERCUT:
			actions.append([Action.ATTACK, "d", Vector2.RIGHT])
		Plan.SPINKICK_SINGLE:
			actions.append([Action.ATTACK, "d", Vector2.DOWN])
		Plan.SPINKICK_FULL:
			actions.append([Action.ATTACK, "d", Vector2.DOWN]) # Hold button
		Plan.LIGHT:
			actions.append([Action.ATTACK, "a", Vector2.ZERO])
		Plan.LOW_LIGHT:
			actions.append([Action.ATTACK, "a", Vector2.DOWN])
		Plan.MED:
			actions.append([Action.ATTACK, "b", Vector2.ZERO])
		Plan.HEAVY:
			actions.append([Action.ATTACK, "c", Vector2.ZERO])
		Plan.LOW_HEAVY:
			actions.append([Action.ATTACK, "c", Vector2.DOWN])
		Plan.ANTI_AIR:
			actions.append([Action.ANTI_AIR])
		Plan.THROW:
			actions.append([Action.THROW])
		Plan.OVERHEAD:
			actions.append([Action.ATTACK, "B", Vector2(1,1)])
		Plan.JUMP_LIGHT:
			actions.append([Action.JUMP, 1])
			actions.append([Action.JUMP_ATTACK, "a"])
		Plan.JUMP_MED:
			actions.append([Action.JUMP, 1])
			actions.append([Action.JUMP_ATTACK, "b"])
		Plan.JUMP_HEAVY:
			actions.append([Action.JUMP, 1])
			actions.append([Action.JUMP_ATTACK, "c"])
		Plan.JUMP_EMPTY:
			actions.append([Action.JUMP, 1])
		Plan.BACKUP_LIGHT:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ATTACK, "a", Vector2.ZERO])
		Plan.BACKUP_LIGHT_LOW:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ATTACK, "a", Vector2.DOWN])
		Plan.BACKUP_MED:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ATTACK, "b", Vector2.ZERO])
		Plan.BACKUP_HEAVY:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ATTACK, "c", Vector2.ZERO])
		Plan.BACKUP_HEAVY_LOW:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ATTACK, "a", Vector2.DOWN])
		Plan.BACKUP_ANTI_AIR:
			actions.append([Action.BACKUP, 20 + rng(10)])
			actions.append([Action.ANTI_AIR])
	
	var action = actions[0]
	match action[0]:
		Action.RUNUP:
			if distance < action[1]:
				actions.pop_front()
			else:
				dir.x = 1
		Action.BACKUP:
			actions.pop_front()
		Action.JUMP:
			dir.x = action[1]
			dir.y = -1
			actions.pop_front()
		Action.ATTACK:
			button[action[1]] = true
			dir = action[2]
			actions.pop_front()
		Action.THROW:
			button.a = true
			button.b = true
			actions.pop_front()
		Action.ANTI_AIR:
			if player.other_player.position.y < player.positon.y:
				button.b = true
				dir.y = 1
				actions.pop_front()
			
	dir.x *= player.facing

func add_plan(option):
	plans.append(option)

func on_attack_hit():
	match player.action:
		"2A", "5A":
			next_button = "b"
		"5B":
			next_button = "c"
		"5C":
			next_button = "d"

func rng(max_amount):
	return randi() % max_amount
