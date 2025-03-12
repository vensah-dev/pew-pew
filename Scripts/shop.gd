@tool
extends StaticBody3D

@onready var canvas = $canvas
@onready var vbox = $canvas/content/bg/ScrollContainer/VBoxContainer
@onready var canvasAnim = $canvas/anim

@onready var player = get_tree().get_first_node_in_group("player")

@export_group("Shop Settings")
@export var numberOfAvailableItems := 5

@export var possibleItems: Array[Item]
@export var itemPrefab: PackedScene

var availableItems = {
	"item":"price"
}
var usedIndecies = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateShop()
	# openShop() # Replace with function body.

# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func generateShop():
	for currentItem in possibleItems:
		var itemUI = itemPrefab.instantiate()

		itemUI.item = currentItem
		vbox.add_child(itemUI)
	

		# var randomIndex = randi_range(0, possibleItems.size()-1)

		# if !usedIndecies.has(randomIndex):
		# 	usedIndecies.append(randomIndex)


func openShop():
	player.freeze(true)

	canvasAnim.play("spawn")
	canvasAnim.advance(0)

func closeShop():
	player.freeze(false)

	canvasAnim.play("byebye")
	canvasAnim.advance(0)

func _on_close_pressed() -> void:
	closeShop()
