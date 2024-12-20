extends Node3D

@export var rotationSpeed = 2.5
@export var spaceStationScene: PackedScene
@export var spawnPoint:Transform3D
@export var entries:Array[Node]

var insideEntry = false

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	SceneSwicther.worldSwitched.connect(movePlayer)

func movePlayer():
	player.transform = spawnPoint

func _process(delta: float) -> void:
	rotate_y(rotationSpeed * delta)

	if insideEntry:
		player.showInteractionLabel("F to enter")
		if Input.is_action_just_pressed("interact"):
			player.hideInteractionLabel()
			insideEntry = false
			SceneSwicther.switchScene(spaceStationScene)

	else:
		player.hideInteractionLabel()

#if entered
func _on_entry_1_entered(body:Node3D) -> void:
	spawnPoint = entries[0].transform
	enterEntry(body)

func _on_entry_2_entered(body:Node3D) -> void:
	spawnPoint = entries[1].transform
	enterEntry(body)


#if exited
func _on_entry_1_exited(body:Node3D) -> void:
	exitEntry(body)
func _on_entry_2_exited(body:Node3D) -> void:
	exitEntry(body)


#what to do if areaNodes are entered
func enterEntry(body):
	# spawnPoint = body.global_transform.translated(Vector3.UP * 50)
	if body.is_in_group("player") && !body.lookingAtInteractable:
		# print("entered entry")

		insideEntry = true

func exitEntry(body):
	# spawnPoint = body.global_transform.translated(Vector3.UP * 50)
	if body.is_in_group("player"):
		# print("entered entry")

		insideEntry = false
