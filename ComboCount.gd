extends MarginContainer

func _ready():
	hide()

func set_combo_count(count, damage):
#	if count > 1:
	if count > 0:
		show()
		$Numbers/Count.text = str(count)
		$Numbers/Damage.text = str(damage)
	elif count == 0:
		$Timer.start()

func _on_Timer_timeout():
	hide()
