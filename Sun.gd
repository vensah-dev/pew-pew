extends Node3D

@export var suns: Array[PackedScene]

@onready var root = get_tree().root.get_child(0)
@onready var rng = RandomNumberGenerator.new()

func _ready():
	root.connect("seed_ready", setSystem)

func setSystem():
	rng.seed = root.spawnSeedHashed
	var randomIndex = rand_from_seed(rng.seed + 4)[0]%suns.size()
	var sun = suns[randomIndex].instantiate()
	add_child(sun)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
