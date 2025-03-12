extends PanelContainer

@export var itemSlots: Array[Node]

@export var activeItemSlotColor: Color
@export var idleItemSlotColor: Color

var items
var selectedIndex


# func _ready() -> void:
		
func updateInventory() -> void:
	for itemSlot in itemSlots:
		itemSlot.get_child(0).texture = null

	for i in range(items.size()):
		itemSlots[i].get_child(0).texture = items[i].icon

	for j in range(itemSlots.size()):
		if j == selectedIndex:
			var activeStyleBox = itemSlots[j].get_theme_stylebox("panel")
			activeStyleBox.bg_color = activeItemSlotColor
			itemSlots[j].add_theme_stylebox_override("panel", activeStyleBox)
		else:
			var activeStyleBox = itemSlots[j].get_theme_stylebox("panel")
			activeStyleBox.bg_color = idleItemSlotColor
			itemSlots[j].add_theme_stylebox_override("panel", activeStyleBox)
