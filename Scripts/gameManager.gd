extends Node

@export var spawnSeed = ""

@onready var rng = RandomNumberGenerator.new()
@onready var player = $player
@onready var world = $world

@onready var fpsLabel = $"UI/FPS"
@onready var currencyLabel = $"UI/currencyLabel"

var currency = 0

signal seed_ready

var spawnSeedHashed: int

func _ready():
	
	if spawnSeed == "":
		spawnSeed = str(randi())
	
	spawnSeedHashed = hash(spawnSeed)
	
	rng.seed = spawnSeedHashed

	seed_ready.emit()

	print("Spawn Seed: " + str(spawnSeed)) 
	print("Spawn Seed Hashed: " + str(spawnSeedHashed))
	
func _process(_delta):
	fpsLabel.text = "FPS " + str(Engine.get_frames_per_second())
	currencyLabel.text = "Currency: " + str(currency)

	
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
