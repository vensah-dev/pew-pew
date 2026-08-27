extends Node

signal seed_ready

@export var spawnSeed = ""

@onready var rng = RandomNumberGenerator.new()
@onready var player = $player
@onready var world = $world

@onready var fpsLabel = $"UI/FPS"

@onready var currencyLabel = $"UI/currencyContainer/currencyLabel"
@onready var expBar = $"UI/EXPBar"
@onready var waveLabel = $"UI/waveLabel"
@onready var expLabel = $"UI/EXPBar/expLabel"


@onready var enemySpawner = $world/EnemySpawner

var waveNumber: int

var currency = 0

@export var expLevel = 1
@export var expCurve: float = 2.0
@export var baseEXP: int = 100
## The bigger the value the slower the animation
## works by making the tween duration be animationSpeed/points
@export var animationSpeed = 50

var totalExperiencePoints: int = 0
var currentExperiencePoints: int = 0 
var expNeededToProgress: int = baseEXP

var spawnSeedHashed: int


func _ready():
	
	if spawnSeed == "":
		spawnSeed = str(randi())
	
	spawnSeedHashed = hash(spawnSeed)
	
	rng.seed = spawnSeedHashed

	seed_ready.emit()

	print("Spawn Seed: " + str(spawnSeed)) 
	print("Spawn Seed Hashed: " + str(spawnSeedHashed))

	await get_tree().process_frame

	expBar.value = currentExperiencePoints
	expBar.max_value = expNeededToProgress
	expLabel.text = "0"
	waveLabel.text = str(expLevel)
	
func _process(_delta):
	fpsLabel.text = "FPS " + str(Engine.get_frames_per_second())
	currencyLabel.text = str(currency)

	waveNumber = enemySpawner.waveNumber

	if Input.is_action_just_pressed("gyroscope"):
		addEXP(5000)

func getExpNeededToProgress(level: int):
	return int(baseEXP * pow(level, expCurve))

func addEXP(points: int):
	totalExperiencePoints += points
	currentExperiencePoints += points

	while expBar.max_value <= currentExperiencePoints:
		var overflowExperiencePoints = currentExperiencePoints - expBar.max_value
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(expBar, "value", expBar.max_value, 0.3)
		await tween.finished

		currentExperiencePoints = overflowExperiencePoints

		expLevel += 1
		waveLabel.text = str(expLevel)
		expBar.max_value = getExpNeededToProgress(expLevel)
		expBar.value = 0

	var finalTween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD)
	finalTween.tween_property(expBar, "value", currentExperiencePoints, 0.3)
	await finalTween.finished
	expLabel.text = str(totalExperiencePoints)


# func set_currentExperiencePoints(new_value: int) -> void:
# 	if new_value >= expBar.max_value:
# 		overflowExperiencePoints = new_value - expBar.max_value
# 		currentExperiencePoints = 0
# 		expLevel += 1
# 		expBar.max_value = getExpNeededToProgress(expLevel)

# 		currentExperiencePoints = overflowExperiencePoints
# 		overflowExperiencePoints = 0

# 		print("New EXP Level: ", getExpNeededToProgress(expLevel))

# 	expBar.value = new_value
# 	expLabel.text = str(new_value)

# func set_expNeededToProgress(new_value: int) -> void:
# 	expBar.max_value = new_value

##seed random functions
func randomf(x):
	var newrng = RandomNumberGenerator.new()
	newrng.seed = x
	return newrng.randf()
	
func randomi(x):
	var newrng = RandomNumberGenerator.new()
	newrng.seed = x
	return newrng.randi()
	
func randomf_range(minVal: float, maxVal: float, x: int):
	var newrng = RandomNumberGenerator.new()
	newrng.seed = x
	return newrng.randf_range(minVal, maxVal)
	
func randomi_range(minVal: int, maxVal: int, x: int):
	var newrng = RandomNumberGenerator.new()
	newrng.seed = x
	return newrng.randi_range(minVal, maxVal)
