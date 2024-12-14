extends Node3D

@export var stars: Array[PackedScene]
@export var bodySpacingBuffer = 2.0
@export var areaBuffer = 100000.0
@export var spawnSeed: int

@onready var root = get_tree().root.get_child(0)
@onready var gameManager = get_tree().get_first_node_in_group("gameManager")

@onready var rng = RandomNumberGenerator.new()

@onready var planetNode = $Planets
@onready var areaNode = $Area

var distToStar: float

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
	star.position = Vector3(0, 0, 0)
	add_child(star)
	
	distToStar = star.scale.z

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
		# children[i].rotation_degrees.x = root.randomi_range(-360, 360, i)
		# children[i].rotation_degrees.y = root.randomi_range(-360, 360, i+1)

		var child = children[i]

		child.position = Vector3(0, 0, 0)
		distToStar += child.scale.z*bodySpacingBuffer
		child.rigidbody.global_position.z += distToStar
		distToStar += child.scale.z*bodySpacingBuffer
		
		var randomRotationSpeed = Vector3(0, gameManager.randomf(i)/distToStar, 0)
		child.pivotRotationalSpeed = randomRotationSpeed

		# children[i].rotation_degrees.x = root.randomi_range(-360, 360, i+3)
		child.rotation_degrees.y = gameManager.randomi_range(-360, 360, i)
		child.rigidbody.rotation_degrees.x = gameManager.randomi_range(-360, 360, i+1)
		child.axisRotationalSpeed = Vector3(0, gameManager.randomf(i)/inverse_lerp(child.size.min, child.size.max, child.scale.z)/1000, 0)






		
	areaNode.scale = Vector3(distToStar*areaBuffer, distToStar*areaBuffer, distToStar*areaBuffer)


	# print(self, " | AreaNode Scale:", areaNode.scale)
