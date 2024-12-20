extends PanelContainer

@export var item: Item

@onready var title = $margin/flow/details/title
@onready var description = $margin/flow/details/description
@onready var icon = $margin/flow/icon
@onready var buyButton = $margin/flow/buy

@onready var gameManager = get_tree().get_first_node_in_group("gameManager")
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
    item.player = player
    item.generateRandomPrice()
    
    resetUI()
	
func _process(_delta: float) -> void:
    resetUI()

    if gameManager.currency < item.price:
        buyButton.disabled = true

    elif player.inventoryFull():
        buyButton.text = "inventory full"
        buyButton.disabled = true


func _on_buy_pressed() -> void:
    if gameManager.currency > item.price:
        gameManager.currency -= item.price
        player.addItem(item)

    if gameManager.currency < item.price:
        buyButton.disabled = true

func resetUI():
    buyButton.disabled = false
    title.text = item.name
    description.text = item.description
    buyButton.text =  "$" + str(item.price)
