extends CharacterBody3D

@export var maxSpeed = 50.0
@export var stoppingDistance = 25.0
@export var surroundRadius = 100.0
@export var acceleration = 10.0   
@export var turningSpeed = 2.5
@export var explode:PackedScene

@onready var player = get_tree().get_nodes_in_group("player")[0]

@onready var previousLocation = global_position
@onready var destination = random_point_in_sphere_surface(player.global_position, surroundRadius)

@onready var healthData = $healthData
@onready var collider = $boxCollider
@onready var mesh = $mesh
@onready var guns = $mesh/Guns

var rng = RandomNumberGenerator.new()

var state = "chasing"

var speed = maxSpeed

var lookTarget 

func _ready() -> void:
	healthData.setHealth(healthData.maxHealth)

func _process(delta: float) -> void:
	# print("enemy health: ", healthData.health)
	# if healthData.health <= 0 and state != "dead":
	# 	die()

	if global_position.distance_to(player.global_position) >= 10000:
		queue_free()

	if state == "idle":
		state = "choosing next destination"
		previousLocation = global_position
		# await get_tree().create_timer(5.0).timeout
		destination = random_point_in_sphere_surface(player.global_position, surroundRadius)
		# smoothed_destination = lerp(smoothed_destination, destination, 0.01)
		# look_at(smoothed_destination.snapped(Vector3.ONE), Vector3.UP, true)
		state = "attack"
		print(self,"state: ", state)

	if state == "chasing":
		# state = "chasing"

		# var targetTransform = transform.looking_at(destination, transform.basis.y, true)

		# rotation = lerp(rotation, targetTransform.)

		# self.transform  = self.transform.interpolate_with(, turningSpeed * delta)
		# transform = transform.looking_at(destination, Vector3.UP)

		lookAtButSmooth(destination, delta)

		speed = maxSpeed

		var totalDistanceToDestination = previousLocation.distance_to(destination)
		var accelerateDistance = totalDistanceToDestination/acceleration
		
		if global_position.distance_to(destination) <= accelerateDistance:
			speed = maxSpeed * inverse_lerp(0, accelerateDistance, global_position.distance_to(destination)) + 10

		elif global_position.distance_to(destination) >= totalDistanceToDestination-accelerateDistance:
			speed = maxSpeed * (1-inverse_lerp(totalDistanceToDestination-accelerateDistance, totalDistanceToDestination, global_position.distance_to(destination))) + 10

		if destination.distance_to(global_position) < stoppingDistance:
			# print("smoothed_destination.snapped(Vector3.ONE * stoppingDistance):", smoothed_destination.snapped(Vector3.ONE * stoppingDistance))
			# print("destination.snapped(Vector3.ONE * stoppingDistance):", destination.snapped(Vector3.ONE * stoppingDistance))

			velocity = Vector3.ZERO
			# await get_tree().create_timer(1.0).timeout

			state = "idle"
			print(self,"state: ", state)

		else:
			velocity = (destination-global_position).normalized() * speed
			# state = "chase"

	if state == "attack":
		
		if lookAtButSmooth(player.global_position, delta) == true:
			var random = 5
			velocity = Vector3.ZERO
			shoot(random)

			await get_tree().create_timer(guns.reloadInterval * (random+2)).timeout
			state = "chasing"
			print(self, "state: ", state)

		# await get_tree().create_timer(1.0).timeout

func shoot(times):
		for i in range(times):
			if guns.canShoot:
				guns.shoot()



func _physics_process(_delta: float) -> void:
	move_and_slide()

var addedDelta = 0.0
func lookAtButSmooth(target, delta):
		addedDelta += turningSpeed * delta
		if addedDelta > 1.0:
			addedDelta = 1.0

		var target_vector = global_position.direction_to(target)
		var target_basis= Basis.looking_at(-target_vector)
		basis = basis.slerp(target_basis, turningSpeed * delta)
		
		#if basis.get_scale().snapped(Vector3(0.01, 0.01, 0.01)) == target_basis.get_scale().snapped(Vector3(0.01, 0.01, 0.01)):
		if basis.is_equal_approx(target_basis):
			return true
		else:
			return false


func hit(damage):
	healthData.setHealth(healthData.health - damage)
	print(self, "health: ", healthData.health)

	if healthData.health <= 0:
		collider.disabled = true
		mesh.visible = false
		die()

func die():
	state = "dead"
	velocity = Vector3.ZERO
	# print(state)

	# collider.visible = false	
	# mesh.visible = false

	var explosion = explode.instantiate()
	add_child(explosion)

	await get_tree().create_timer(3.0).timeout
	queue_free()

func random_point_in_sphere_surface(target, radius) -> Vector3:
	var random_direction = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	return target + random_direction * radius
