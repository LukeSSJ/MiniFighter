extends MarginContainer

func update_hp(index, hp):
	if index == 0:
		$Bars/HealthBar.update_hp(hp)
	else:
		$Bars/HealthBar2.update_hp(hp)

func set_wins(index, wins):
	if index == 0:
		$Bars/HealthBar.set_wins(wins)
	else:
		$Bars/HealthBar2.set_wins(wins)
