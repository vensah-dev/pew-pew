class_name HealthManipulationFunction
extends Resource

@export var addHealth: float
@export var addMaxHealth: float

func act(player):
    if addHealth > 0:
        player.healthData.health += addHealth

    elif addMaxHealth > 0:
        player.healthData.maxHealth += addMaxHealth
