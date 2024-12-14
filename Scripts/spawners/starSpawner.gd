extends Node3D

@export var numberOfComets = 300
@export var spawnRadius = 3000
@export var size = {"min": 5, "max": 15}

@export var stars: Array[PackedScene]

@onready var main = get_tree().current_scene

@onready var rng = RandomNumberGenerator.new()

@onready var root = get_tree().root.get_child(0)
@onready var gameManager = get_tree().get_first_node_in_group("gameManager")

@onready var player = $"../../../player"

func _ready():
	gameManager.connect("seed_ready", spawnStars)

func spawnStars():
	rng.seed = hash(gameManager.spawnSeed)
	
	for x in numberOfComets:
		var randomIndex = rand_from_seed(rng.seed + x)[0]%stars.size()
		var star = stars[randomIndex].instantiate()
		star.transform = transform
		add_child(star)

		var randomy = rng.randi_range(0, 360)
		var randomx = rng.randi_range(0, 360)
		var randomz = rng.randi_range(0, 360)
		
		var quaternionRot = Quaternion.from_euler(Vector3(randomy, randomx, randomz))	
		transform.basis *= Basis(quaternionRot)
		
		star.position += transform.basis * Vector3(0, 0, spawnRadius)
		
		star.scale *= rng.randi_range(size.min, size.max)
		
#func _process(delta):
	#position = player.position
