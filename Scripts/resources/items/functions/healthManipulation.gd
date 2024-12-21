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
        player.healthData.health += addHealth
        print("health ", player.healthData.health)

    elif addMaxHealth > 0:
        player.healthData.maxHealth += addMaxHealth
        print("maxHealth ", player.healthData.maxHealth)

    elif addMaxShield > 0:
        player.healthData.maxShield += addMaxShield
        print("maxShield ", player.healthData.maxShield)

    elif addShieldRegen > 0:
        player.healthData.shieldRegenPerUnit += addShieldRegen
        print("shieldRegenPerUnit ", player.healthData.shieldRegenPerUnit)
