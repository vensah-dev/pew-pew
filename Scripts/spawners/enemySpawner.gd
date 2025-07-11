extends Node3D

@export_group("Enemies")
@export var enemiesPerWave = 5
@export var enemies: Array[PackedScene]
@export var player: Node3D

@export_group("Spawn")
@export var spawnRadius = 250.0

@export_group("UI")
@export var waveLabel: Label
@export var enemyLabel: Label

@onready var root = get_tree().current_scene

var waveNumber:int = 0

var currentEnemies = []
var currentWave


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	spawnWave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	waveLabel.text = "Wave: " + str(waveNumber)
	enemyLabel.text = "Enemies Left: " + str(currentEnemies.size())

	if currentEnemies.size() == 0:
		spawnWave()

	# spawnWave()
	# await get_tree().create_timer(180).timeout

func spawnWave():
	waveNumber += 1
	for i in range(0, enemiesPerWave):
		var randomNumber = randi_range(0, enemies.size()-1)
		var enemy = enemies[randomNumber].instantiate()

		enemy.player = player
		enemy.enemySpawner = self
		enemy.position = random_point_in_sphere_surface(global_position, spawnRadius)

		currentEnemies.append(enemy)
		add_child(enemy)


func random_point_in_sphere_surface(target, radius) -> Vector3:
	var random_direction = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	return target + random_direction * radius
