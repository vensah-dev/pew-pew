class_name healthNode
extends Node

signal health_changed(value)

@export var maxHealth:int = 100
var health:int:
	set = setHealth

func getHealth():
	return health 

func getMaxHealth():
	return maxHealth

func setHealth(value):
	health = value
	if health < 0:
		health = 0
	else:
		health_changed.emit(health)
