extends CanvasLayer

onready var combo_count
onready var HealthBars = [$HealthBar, $HealthBar2]
onready var SpecialBars = [$SpecialBar, $SpecialBar2]

func update_timer(time):
	$Clock/Label.text = str(time)
	
func set_combo_count(player):
	$ComboCounts.get_child(player.index).set_combo_count(player.combo_count, player.combo_damage)

func update_hp(index, hp):
	HealthBars[index].update_hp(hp)

func set_wins(index, wins):
	HealthBars[index].set_wins(wins)

func update_special(index, special):
	SpecialBars[index].value = special
