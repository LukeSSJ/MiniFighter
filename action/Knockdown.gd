extends Node2D

func can_recover():
	owner.can_recover = true

func recover():
	owner.perform_action("Recover")
