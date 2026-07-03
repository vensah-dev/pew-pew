extends Node

signal worldSwitched

@onready var rootScene = get_tree().root.get_child(get_tree().root.get_child_count()-1)
var currentWorld = null
var prevWorld = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentWorld = rootScene.get_child(rootScene.get_child_count()-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# currentScene = get_tree().root.get_child(get_tree().root.get_child_count()-1)
	print("currentWorld: ", currentWorld)
	print("prevWorld: ", prevWorld)


func switchScene(newWorld: PackedScene, world = false) -> void:
	if world:
		currentWorld = get_tree().current_scene.get_child(0).get_child(-1)
		print("currentWorld2: ", currentWorld)
	else:
		currentWorld = rootScene.get_child(rootScene.get_child_count()-1)

	call_deferred("_deferredSwitchScene", newWorld, world) # pscene.resource_path grabs the path to the provided PackedScene and returns a string

func _deferredSwitchScene(newWorld, world) -> void:

	if !world:
		rootScene.remove_child(currentWorld)
		prevWorld = currentWorld
		var newWorldInstance = newWorld.instantiate()
		rootScene.add_child(newWorldInstance)
		currentWorld = newWorldInstance
		# var player = body.instantiate()
		
	else:
		get_tree().current_scene.get_child(0).remove_child(currentWorld)
		prevWorld = currentWorld
		var newWorldInstance = newWorld.instantiate()
		get_tree().current_scene.get_child(0).add_child(newWorldInstance)
		currentWorld = newWorldInstance
		# var player = body.instantiate()
		
	worldSwitched.emit(currentWorld)
	print("currentWorld3: ", currentWorld)


func switchSceneBack(world = false) -> void:
	call_deferred("_deferredSwitchSceneBack", world) # pscene.resource_path grabs the path to the provided PackedScene and returns a string

func _deferredSwitchSceneBack(world = false) -> void:
	if !world:
		rootScene.remove_child(currentWorld)
		rootScene.add_child(prevWorld)

		prevWorld = currentWorld
		currentWorld = rootScene.get_child(rootScene.get_child_count()-1)
	else:
		# get_tree().current_scene.get_child(0) is the reference to the game node under the rootScene node (not root node)
		get_tree().current_scene.get_child(0).remove_child(currentWorld)
		get_tree().current_scene.get_child(0).add_child(prevWorld)

		prevWorld = currentWorld
		currentWorld = get_tree().current_scene.get_child(0).get_child(get_tree().current_scene.get_child(0).get_child_count()-1)

	# var player = body.instantiate()
	worldSwitched.emit(currentWorld)
