extends Node

signal worldSwitched

@onready var game = get_tree().root.get_child(get_tree().root.get_child_count()-1)
var currentWorld = null
var prevWorld = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentWorld = game.get_child(game.get_child_count()-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# currentScene = get_tree().root.get_child(get_tree().root.get_child_count()-1)
	print("currentWorld: ", currentWorld)
	print("prevWorld: ", prevWorld)


func switchScene(newWorld: PackedScene) -> void:
	call_deferred("_deferredSwitchScene", newWorld) # pscene.resource_path grabs the path to the provided PackedScene and returns a string

func switchSceneBack() -> void:
	call_deferred("_deferredSwitchSceneBack") # pscene.resource_path grabs the path to the provided PackedScene and returns a string

func _deferredSwitchScene(newWorld) -> void:
	game.remove_child(currentWorld)
	prevWorld = currentWorld
	var newWorldInstance = newWorld.instantiate()
	game.add_child(newWorldInstance)
	currentWorld = newWorldInstance
	# var player = body.instantiate()
	
	worldSwitched.emit()

func _deferredSwitchSceneBack() -> void:
	game.remove_child(currentWorld)
	game.add_child(prevWorld)

	prevWorld = currentWorld
	currentWorld = game.get_child(game.get_child_count()-1)

	# var player = body.instantiate()

	worldSwitched.emit()
