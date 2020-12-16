extends MarginContainer

func update_hp(index, hp):
	if index == 0:
		$Bars/HealthBar.update_hp(hp)
	else:
		$Bars/HealthBar2.update_hp(hp)
