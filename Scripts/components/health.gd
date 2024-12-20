class_name healthNode
extends Node

signal health_changed(value)
signal shield_changed(value)

@export var maxHealth:float = 100
var health:float:
	set = setHealth

@export var maxShield:float = 100
var shield:float:
	set = setShield

@export_group("Shield Regeneration")
@export var regenPerUnit = 0.02
@export var timeToRegenAfterHit = 5.0

var shieldRegenTimer: Timer
var regeningShield = false

func getHealth():
	return health 

func getMaxHealth():
	return maxHealth

func setHealth(value):
	health = value
	if health < 0:
		health = 0
	elif health > maxHealth:
		health = maxHealth
	else:
		health_changed.emit(health)

func setShield(value):
	shield = value
	if shield < 0:
		shield = 0
	else:
		shield_changed.emit(shield)

func startRegenShield():

	if shield < maxShield:
		shieldRegenTimer.stop()
		regeningShield = false
		shieldRegenTimer.start()
		await shieldRegenTimer.timeout
		regeningShield = true
	else:
		shieldRegenTimer.stop()
		regeningShield = false

func regenShield(amount):
	if regeningShield and shield < maxShield:
		shield += amount

func _ready() -> void:
	shieldRegenTimer = Timer.new()
	shieldRegenTimer.wait_time = timeToRegenAfterHit
	add_child(shieldRegenTimer)
	
func _physics_process(_delta: float) -> void:
	regenShield(regenPerUnit)