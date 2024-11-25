extends Node3D

@export var maxNumber = 100
@export var minNumber = 100
@export var maxSpawnRadius = 50.0
@export var minSpawnRadius = 0.0
@export var bodySpacingBuffer = 10.0
@export var aoidOverlap = true

@export var solarSystems: Array[PackedScene]

@onready var rng = RandomNumberGenerator.new()

@onready var root = get_tree().root.get_child(0)

var spawnedSystems: Array

var maxSpawnDiameter = maxSpawnRadius*2

func _ready():
	root.connect("seed_ready", spawn_systems)
	
func in_another_body(bodyInstance):
	for b in spawnedSystems:
		if bodyInstance != b:
			var distanceBetweenSystems = bodyInstance.position.distance_to(b.position) - (bodyInstance.areaNode.scale.z/2 + b.areaNode.scale.z/2)
			if distanceBetweenSystems < ((bodyInstance.areaNode.scale.z/2 + b.areaNode.scale.z/2)*bodySpacingBuffer):
				return true

	return false

func spawn_systems():
	rng.seed = root.spawnSeedHashed
	print("spawner: " + str(rng.seed))
	
	var numberOfSystems = root.randomi_range(minNumber, maxNumber, rng.seed)
	for x in numberOfSystems:
		var randomIndex = rand_from_seed(rng.seed + x)[0]%solarSystems.size()
		var bodyInstance = solarSystems[randomIndex].instantiate()
		
		var randomPosition = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)
		bodyInstance.position = randomPosition

		bodyInstance.spawnSeed = rng.seed + x
		add_child(bodyInstance)
		bodyInstance.setSystem()

		while in_another_body(bodyInstance):
			bodyInstance.position = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)


		print("Position of ", bodyInstance, ": ", bodyInstance.position)

		spawnedSystems.append(bodyInstance)

#func _process(delta):
	#for i in spawnedBodies.size():
		#if 0 >= i and i < spawnedBodies.size():
			#var bodyInstance = spawnedBodies[i]
			#if is_instance_valid(bodyInstance):
				#if root.player.position.distance_to(bodyInstance.position) < bodyInstance.visibilityRange:
					#bodyInstance.get_parent().remove_child(bodyInstance)
					#add_child(bodyInstance)
					#spawnedBodies.remove_at(i)
#
	#var children = self.get_children()
	#for c in children:
		#if root.player.position.distance_to(c.position) > c.visibilityRange:
			#update position and data
			#spawnedBodies.append(c)
			#remove_child(c)
			#c.queue_free()
			#
	#print(children.size())

func random_point_in_sphere(minRadius, maxRadius) -> Vector3:
	var random_direction = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
	var random_radius = rng.randf_range(minRadius, maxRadius)
	return global_position + random_direction * random_radius
	
