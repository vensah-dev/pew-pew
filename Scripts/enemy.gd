extends CharacterBody3D

@export var maxSpeed = 50.0
@export var stoppingDistance = 25.0
@export var surroundRadius = 100.0
@export var acceleration = 10.0   
@export var turningSpeed = 1.0
@export var explode:PackedScene

@onready var player = get_tree().get_nodes_in_group("playerNode")[0]

@onready var previousLocation = global_position
@onready var destination = random_point_in_sphere_surface(player.global_position, surroundRadius)

@onready var collider = $boxCollider
@onready var mesh = $mesh
@onready var healthData = $health


var state = "idle"

var speed = maxSpeed

var smoothed_destination: Vector3

var addedDelta = 0.0

func _ready() -> void:
	healthData.setHealth(healthData.maxHealth)

func _process(delta: float) -> void:
	# print("enemy health: ", healthData.health)
	# if healthData.health <= 0 and state != "dead":
	# 	die()

	if state == "idle":
		state = "choosing next destination"
		previousLocation = global_position
		# await get_tree().create_timer(5.0).timeout
		destination = random_point_in_sphere_surface(player.global_position, surroundRadius)
		# smoothed_destination = lerp(smoothed_destination, destination, 0.01)
		# look_at(smoothed_destination.snapped(Vector3.ONE), Vector3.UP, true)
		state = "chasing"
		# print(state)

	if state == "chasing":

		transform  = transform.interpolate_with(transform.looking_at(destination, transform.basis.y, true), turningSpeed * delta)
		# transform = transform.looking_at(destination, Vector3.UP)

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
			state = "idle"
			# print(state)

		else:
			velocity = transform.basis.z * speed

func _physics_process(_delta: float) -> void:
	move_and_slide()

func hit(damage):
	healthData.setHealth(healthData.health - damage)
	print(self, "health: ", healthData.health)

	if healthData.health <= 0:
		collider.disabled = true
		mesh.visible = false
		die()

func die():
	state = "dead"
	velocity = Vector3.ONE
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
