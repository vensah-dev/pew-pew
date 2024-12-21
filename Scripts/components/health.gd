class_name healthNode
extends Node

signal health_changed(value)
signal max_health_changed(value)

signal shield_changed(value)
signal max_shield_changed(value)

@export var maxHealth:float = 100:
	set = setMaxHealth
var health:float:
	set = setHealth

@export var maxShield:float = 100:
	set = setMaxShield
var shield:float:
	set = setShield

@export_group("Shield Regeneration")
@export var shieldRegenPerUnit = 0.02
@export var timeToRegenShieldAfterHit = 5.0

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
	health_changed.emit(health)

func setShield(value):
	shield = value
	if shield < 0:
		shield = 0
	elif shield > maxShield:
		shield = maxShield
		
	shield_changed.emit(shield)

func setMaxShield(value):
	maxShield = value
	max_shield_changed.emit(maxShield)

func setMaxHealth(value):
	maxHealth = value
	max_health_changed.emit(maxShield)

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
	shieldRegenTimer.wait_time = timeToRegenShieldAfterHit
	add_child(shieldRegenTimer)
	
func _physics_process(_delta: float) -> void:
	regenShield(shieldRegenPerUnit)
