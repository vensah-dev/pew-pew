extends Node3D

@export var stars: Array[PackedScene]
@export var bodySpacingBuffer = 2.0
@export var areaBuffer = 10000.0
@export var spawnSeed: int

@onready var root = get_tree().root.get_child(0)
@onready var rng = RandomNumberGenerator.new()

@onready var planetNode = $Planets
@onready var areaNode = $Area

var closestDistToStar: float

func _ready():
	print("solar system: " + str(spawnSeed))
	#root.connect("seed_ready", setSystem)
	#setSystem()

func setSystem():
	#rng.seed = root.spawnSeedHashed
	rng.seed = spawnSeed
	set_star()
	set_planets()
	
func set_star():
	var randomIndex = rand_from_seed(rng.seed + 4)[0]%stars.size()
	var star = stars[randomIndex].instantiate()
	var randomSize = rng.randi_range(star.size.min, star.size.max)
	star.scale = Vector3(randomSize, randomSize, randomSize)
	add_child(star)
	
	closestDistToStar = star.scale.z

func set_planets():
	##delete all the children in case some planets were already generated
	#for n in planetNode.get_children():
		#planetNode.remove_child(n)
		#n.queue_free()
		#
		
	planetNode.spawnSeed = spawnSeed
	planetNode.spawn_body()
	
	var children = planetNode.get_children()
	for i in children.size():
		closestDistToStar += children[i].scale.z*bodySpacingBuffer
		children[i].rigidbody.global_position.z += closestDistToStar
		closestDistToStar += children[i].scale.z*bodySpacingBuffer
		
		var randomRotationSpeed = Vector3(0, (root.randomf(i)/children[i].scale.z), 0)
		children[i].pivotRotationalSpeed = randomRotationSpeed
		children[i].rotation_degrees.y = root.randomi_range(0, 360, i)
		
	areaNode.scale = Vector3(closestDistToStar+areaBuffer, closestDistToStar+areaBuffer, closestDistToStar+areaBuffer)