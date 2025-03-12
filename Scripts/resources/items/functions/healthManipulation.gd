class_name HealthManipulationFunction
extends Resource

@export var addHealth: float
@export var addMaxHealth: float

@export var addShieldRegen: float
@export var addMaxShield: float

func purchased(player):
	player.addItem(self)

func act(player):
	
	if addHealth > 0:
		player.vignette.get_material().set_shader_parameter("vignette_color", player.regenVignetteColor) 
		player.healthData.health += addHealth

	elif addMaxHealth > 0:
		player.healthData.maxHealth += addMaxHealth

	elif addMaxShield > 0:
		player.healthData.maxShield += addMaxShield

	elif addShieldRegen > 0:
		player.healthData.shieldRegenPerUnit += addShieldRegen
