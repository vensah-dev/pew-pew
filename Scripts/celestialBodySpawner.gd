extends Node3D

@export var minNumberOfBodies = 100
@export var maxNumberOfBodies = 100
@export var maxSpawnRadius = 50.0
@export var minSpawnRadius = 0.0
@export var bodySpacingBuffer = 2.0
@export var randomizePositions = true
@export var aoidOverlap = true
@export var spawnSeed: int = 0

@export var bodies: Array[PackedScene]

@onready var rng = RandomNumberGenerator.new()

@onready var root = get_tree().root.get_child(0)

var takenPositions = [{}]

var spawnedBodies: Array

func _ready():
	root.connect("seed_ready", set_seed)
	
func in_another_body(bodyInstance):
	for b in spawnedBodies:
		if bodyInstance != b:
			if bodyInstance.position.distance_to(b.position) < ((bodyInstance.size.z)*bodySpacingBuffer):
				return true
	return false
	
func set_seed():
	spawnSeed = root.spawnSeedHashed
	spawn_body()

func spawn_body():
	rng.seed = spawnSeed
	
	print("Celestial Spawner: " + str(spawnSeed))
	
	var numberOfBodies = root.randomi_range(minNumberOfBodies, maxNumberOfBodies, rng.seed)

	for x in numberOfBodies:
		var randomIndex = rand_from_seed(rng.seed + x)[0]%bodies.size()
		var bodyInstance = bodies[randomIndex].instantiate()

		var randomSize = root.randomi_range(bodyInstance.size.min, bodyInstance.size.max, x)
		bodyInstance.scale = Vector3(randomSize, randomSize, randomSize)

		if randomizePositions:
			bodyInstance.position = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)
			if aoidOverlap:
				while in_another_body(bodyInstance):
					bodyInstance.position = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)

		else:
			bodyInstance.position = global_position
			
		add_child(bodyInstance)
		spawnedBodies.append(bodyInstance)

# func _process(_delta):
	#for i in spawnedBodies.size():
		#if 0 >= i and i < spawnedBodies.size():
			#var bodyInstance = spawnedBodies[i]
			#if is_instance_valid(bodyInstance):
				#if root.player.position.distance_to(bodyInstance.position) < bodyInstance.visibilityRange:
					#bodyInstance.get_parent().remove_child(bodyInstance)
					#add_child(bodyInstance)
					#spawnedBodies.remove_at(i)
#
	# var children = self.get_children()
	#for c in children:
		#if root.player.position.distance_to(c.position) > c.visibilityRange:
			##update position and data
			#spawnedBodies.append(c)
			#remove_child(c)
			#c.queue_free()
			#
	# print("children.size(): ", children.size())

func random_point_in_sphere(minRadius, maxRadius) -> Vector3:
	var random_direction = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
	var random_radius = rng.randf_range(minRadius, maxRadius)
	return global_position + random_direction * random_radius
	
