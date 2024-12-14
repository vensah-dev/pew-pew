extends Node3D

@export var rotationSpeed = 2.5
@export var spaceStationScene: PackedScene
@export var spawnPoint:Transform3D
@export var entries:Array[Node]

var insideEntry = false

@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneSwicther.worldSwitched.connect(movePlayer)

func movePlayer():
	player.transform = spawnPoint

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(rotationSpeed * delta)

	if insideEntry && Input.is_action_just_pressed("interact"):
		player.hideInteractionLabel()
		insideEntry = false
		SceneSwicther.switchScene(spaceStationScene)

#extry point 1
func _on_entry_1_entered(body:Node3D) -> void:
	spawnPoint = entries[0].transform
	enterSpaceStation(body)

#extry point 2
func _on_entry_2_entered(body:Node3D) -> void:
	spawnPoint = entries[1].transform
	enterSpaceStation(body)

#what to do if areaNodes are entered
func enterSpaceStation(body):
	# spawnPoint = body.global_transform.translated(Vector3.UP * 50)
	if body.is_in_group("player"):
		# print("entered entry")

		body.showInteractionLabel("F to enter")
		insideEntry = true
