class_name AddWeapon
extends Resource

@export var weapon: PackedScene
# func purchased(player):
#     player.addItem(self)

func act(player):
	var weaponClone = weapon.instantiate()
	weaponClone.ship = player
	weaponClone.cam = player.cam

	player.weapons.add_child(weaponClone)
	weaponClone.set_process(false)

	player.listOfGuns.append(weaponClone)
	player.addItem(weaponClone)
