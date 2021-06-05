extends MarginContainer

onready var N1 = $Numbers/Count/MC/Number
onready var N2 = $Numbers/Count/MC2/Number

func _ready():
	hide()

func set_combo_count(count, damage):
	if count > 0:
		show()
		count = min(count, 99)
		var n2 = count % 10
		var n1 = (count - n2) / 10
		if n1 > 0:
			N1.show()
			N1.frame = int(n1)
		else:
			N1.hide()
		N2.frame = int(n2)
		$Numbers/Damage.text = str(damage * 10)
		$AP.play("Add")
		$Timer.stop()
	elif count == 0:
		$Timer.start()

func _on_Timer_timeout():
	hide()
