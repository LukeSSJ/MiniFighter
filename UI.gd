extends CanvasLayer

signal rematch

onready var HealthBars = [$HealthBar, $HealthBar2]
onready var SpecialBars = [$SpecialBar, $SpecialBar2]

func _ready():
	$Rematch.hide()

func round_start(number):
	if number == 3:
		$Round.text = "Final Round"
	else:
		$Round.text = "Round " + str(number)
	$AP.play("RoundStart")

func show_result(text):
	print(text)
	$Result.text = text
	$AP.play("ShowResult")

func update_timer(time):
	$Clock/Label.text = str(time)
	
func set_combo_count(player):
	if player.combo_count > 0:
		var x = 178
		if player.position.x > 512:
			x = 778
		$ComboCount.rect_position.x = x
	$ComboCount.set_combo_count(player.combo_count, player.combo_damage)

func update_hp(index, hp):
	HealthBars[index].update_hp(hp)

func set_wins(index, wins):
	HealthBars[index].set_wins(wins)

func update_special(index, special):
	SpecialBars[index].value = special

func show_rematch():
	$Rematch.show()
	$Rematch/List/Rematch.grab_focus()

func _on_Rematch_pressed():
	$Rematch.hide()
	emit_signal("rematch")

func _on_BackToMenu_pressed():
	get_tree().change_scene("res://Menu.tscn")
