extends Resource
class_name Item

enum ITEM_TYPE {CONSUMABLE, WEAPON}

@export var name: StringName
@export var description: StringName
@export var icon: Texture2D
@export var priceRange = {"min": 0, "max": 10}
@export var function: Resource
@export var immediate = false
@export var type: ITEM_TYPE

var price = priceRange.min

var player

func generateRandomPrice():
	var randomPrice = randi_range(priceRange.min, priceRange.max)
	price = randomPrice

func use():
	function.act(player)
