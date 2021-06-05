extends MarginContainer

func _ready():
	set_wins(0)

func update_hp(amount):
	$Bars/HealthBar.value = amount

func set_wins(wins):
	var Wins = $Bars/Wins
	for i in range(Wins.get_child_count()):
		if wins > i:
			Wins.get_child(i).show()
		else:
			Wins.get_child(i).hide()
