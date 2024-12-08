class_name healthNode
extends Node

signal health_changed(value)
signal shield_changed(value)

@export var maxHealth:int = 100
var health:int:
	set = setHealth

@export var maxShield:int = 100
var shield:int:
	set = setShield

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

func setShield(value):
	shield = value
	if shield < 0:
		shield = 0
	else:
		shield_changed.emit(shield)

