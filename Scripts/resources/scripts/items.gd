extends Resource
class_name Item

enum ITEM_TYPE {CONSUMABLE, UPGRADE, WEAPON}

@export var name: StringName
@export var description: StringName
@export var icon: Texture2D
@export var priceRange = {"min": 0, "max": 10}
@export var function: Resource
@export var immediate = false
@export var type: ITEM_TYPE = ITEM_TYPE.CONSUMABLE

var price = priceRange.min

var player

func purchased():
	if type == ITEM_TYPE.WEAPON:
		function.act(player)
	else:
		player.addItem(self)

func generateRandomPrice():
	var randomPrice = randi_range(priceRange.min, priceRange.max)
	price = randomPrice

func use():
	function.act(player)
