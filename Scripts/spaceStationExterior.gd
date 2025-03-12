extends Node3D

@export var rotationSpeed = 2.5
@export var spaceStationScene: PackedScene
@export var spawnPoint: Node
@export var entries: Array[Area3D]

var insideEntry = false

@onready var player = get_tree().get_first_node_in_group("player")

@onready var anim: AnimationPlayer = $anim

func _ready() -> void:
	SceneSwicther.worldSwitched.connect(movePlayer)

	for entry in entries:
		entry.body_entered.connect(enterEntry)
		entry.body_exited.connect(exitEntry)

func movePlayer(currentWorld):
	print("currentWorld fromm exterior: ", currentWorld)
	if currentWorld != self and currentWorld.is_in_group("spaceStation"):
		currentWorld.playerExitPoint = entries[0]
		# currentWorld.player = player

	# elif currentWorld == self:
	# 	player.transform = entries[0].transform
	# 	player.global_position = Vector3.ZERO

	SceneSwicther.worldSwitched.disconnect(movePlayer)

func _process(delta: float) -> void:
	rotate_y(rotationSpeed * delta)

	if insideEntry:
		player.showInteractionLabel("F to enter")
		if Input.is_action_just_pressed("interact"):
			player.hideInteractionLabel()

			anim.play("Spin")
			var timer = Timer.new()
			timer.wait_time = 9.0
			add_child(timer)
			timer.start()

			await timer.timeout
			if insideEntry:
				SceneSwicther.switchScene(spaceStationScene)

	else:
		player.hideInteractionLabel()

# detect if inside or not
func enterEntry(body):
	print("body: ", body)
	if body.is_in_group("player") && !body.lookingAtInteractable:
		insideEntry = true
func exitEntry(body):
	print("body: ", body)
	if body.is_in_group("player"):
		insideEntry = false
