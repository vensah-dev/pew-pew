extends Node3D

@export var maxNumber = 100
@export var minNumber = 100
@export var maxSpawnRadius = 50.0
@export var minSpawnRadius = 0.0
@export var bodySpacingBuffer = 2.0
@export var aoidOverlap = true

@export var solarSystems: Array[PackedScene]

@onready var rng = RandomNumberGenerator.new()

@onready var root = get_tree().root.get_child(0)

var spawnedSystems: Array

func _ready():
	root.connect("seed_ready", spawn_systems)
	
func in_another_body(bodyInstance):
	for b in spawnedSystems:
		if bodyInstance.origin.distance_to(b.origin) < ((b.areaNode.scale.z)*bodySpacingBuffer):
			return true
	return false

func spawn_systems():
	rng.seed = root.spawnSeedHashed
	print("spawner: " + str(rng.seed))
	
	var numberOfSystems = root.randomi_range(minNumber, maxNumber, 4)
	for x in numberOfSystems:
		var randomIndex = rand_from_seed(rng.seed + x)[0]%solarSystems.size()
		var bodyInstance = solarSystems[randomIndex].instantiate()
		
		bodyInstance.position = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)
		
		#if aoidOverlap:
			#while in_another_body(bodyInstance):
				#bodyInstance.position = random_point_in_sphere(minSpawnRadius, maxSpawnRadius)

		bodyInstance.spawnSeed = rng.seed + x
		add_child(bodyInstance)
		bodyInstance.setSystem()

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
	
