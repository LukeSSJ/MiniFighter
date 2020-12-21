extends CanvasLayer

onready var combo_count

func set_combo_count(player):
	$ComboCounts.get_child(player.index).set_combo_count(player.combo_count, player.combo_damage)

func update_hp(index, hp):
	if index == 0:
		$Top/Bars/HealthBar.update_hp(hp)
	else:
		$Top/Bars/HealthBar2.update_hp(hp)

func set_wins(index, wins):
	if index == 0:
		$Top/Bars/HealthBar.set_wins(wins)
	else:
		$Top/Bars/HealthBar2.set_wins(wins)
