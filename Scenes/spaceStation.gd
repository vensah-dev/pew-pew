extends Node3D

@export var spawnPoint:Node3D

@onready var player = get_tree().get_first_node_in_group("player")


var insideEntry = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneSwicther.worldSwitched.connect(movePlayer)

func movePlayer():
	player.transform = spawnPoint.global_transform

func _process(_delta: float) -> void:
	if insideEntry && Input.is_action_just_pressed("interact"):
		player.hideInteractionLabel()
		insideEntry = false
		SceneSwicther.switchSceneBack()

func _on_exit_entered(body: Node3D) -> void:
	enterSpaceStation(body)

#what to do if areaNodes are entered
func enterSpaceStation(body):
	if body.is_in_group("player"):
		# print("entered entry")

		body.showInteractionLabel("F to enter")
		insideEntry = true
