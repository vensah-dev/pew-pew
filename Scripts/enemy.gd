extends CharacterBody3D

@export var maxSpeed = 50.0
@export var stoppingDistance = 25.0
@export var surroundRadius = 100.0
@export var attackRadius = 10.0
@export var acceleration = 10.0   
@export var turningSpeed = 2.5
@export var explode:PackedScene
@export var despawnDistance: float = 75000
@export var drops: Array[PackedScene]

@export_group("UI")
@export var healthbar:Node
@export var shieldbar:Node

# @export var enemyIndicator:PackedScene

@export var predictionReticleDisapearDistance = 50
@export var healthbarsVisibilityDistance = 100

@onready var player

@onready var previousLocation = global_position
@onready var destination = random_point_in_sphere_surface(player.global_position, surroundRadius)

@onready var healthData = $healthData
@onready var rayCast = $RayCast3D
@onready var collider = $boxCollider
@onready var mesh = $mesh
@onready var guns = $mesh/Guns
@onready var predictionReticle = $mesh/predictionReticle

@onready var root = get_tree().current_scene

var playerGuns 

var rng = RandomNumberGenerator.new()

var state = "chasing"

var speed = maxSpeed

var indicator

@onready var lockedTarget = player

func _ready() -> void:
	healthData.setHealth(healthData.maxHealth)
	healthData.setShield(healthData.maxShield)

	rayCast.scale = Vector3.ONE * guns.bulletRange

	healthData.setHealth(healthData.maxHealth)

	# for child in player.get_children():
	# 	if child.name == "model":

	# 		for kid in child.get_children():
	# 			if kid.name == "Guns":

	# 				playerGuns = kid

	# indicator = enemyIndicator.instantiate()

	# player.ui.add_child(indicator)





func _physics_process(delta: float) -> void:
	playerGuns = player.listOfGuns[player.gunIndex]

	updateHealth()

	# print("enemy health: ", healthData.health)
	# if healthData.health <= 0 and state != "dead":
	# 	die()

	if global_position.distance_to(player.global_position) >= 75000:
		queue_free()

	elif state == "idle":
		state = "choosing next destination"
		previousLocation = global_position
		# await get_tree().create_timer(5.0).timeout
		destination = random_point_in_sphere_surface(player.global_position, surroundRadius)

		# smoothed_destination = lerp(smoothed_destination, destination, 0.01)
		# look_at(smoothed_destination.snapped(Vector3.ONE), Vector3.UP, true)
		state = "attack"
		print(self,"state: ", state)

	elif state == "chasing":
		# state = "chasing OKAY!"

		print(destination)


		lookAtButSmooth(destination, delta)

		
		# speed = maxSpeed

		# var totalDistanceToDestination = previousLocation.distance_to(destination)
		# var accelerateDistance = totalDistanceToDestination/acceleration
		
		# if global_position.distance_to(destination) <= accelerateDistance:
		# 	speed = maxSpeed * inverse_lerp(0, accelerateDistance, global_position.distance_to(destination)) + 10

		# elif global_position.distance_to(destination) >= totalDistanceToDestination-accelerateDistance:
		# 	speed = maxSpeed * (1-inverse_lerp(totalDistanceToDestination-accelerateDistance, totalDistanceToDestination, global_position.distance_to(destination))) + 10


		if destination.distance_to(global_position) < stoppingDistance:

			velocity = Vector3.ZERO
			speed = 0
			# await get_tree().create_timer(1.0).timeout

			state = "idle"
			print(self,"state: ", state)

		else:

			var moveVector = (destination-global_position).normalized()
			velocity = velocity.lerp(moveVector * maxSpeed, delta * acceleration)
			# state = "chasing"

	elif state == "attack":

		# velocity = (destination-global_position).normalized() * speed

		lookAtButSmooth(player.global_position, delta)
		
		var moveVector = (player.global_position - global_position).normalized()
		velocity = velocity.lerp(moveVector * maxSpeed, delta * acceleration)

		if global_position.distance_to(player.global_position) < 50:
			state = "chasing"
			print(self, "state: ", state)

		if rayCast.is_colliding():
			var collided_object = rayCast.get_collider()  
			print("results from enemy: ", collided_object)

			if collided_object.is_in_group("player"):
				shoot(1)

	updatePredictionReticle()

	move_and_slide()

	# var angleToLookAt = Vector3.UP.angle_to(player.global_position)
	
	# # var look_at_transform = self.transform
	# # look_at_transform.looking_at(player.global_position, transform.basis.y) 
	# indicator.look_at(global_position, Vector3.UP)

func accelerate():

	speed *= acceleration

	if speed >= maxSpeed:
		speed = maxSpeed

func lookAtButSmooth(target, delta):

		var target_vector = global_position.direction_to(target)
		var target_basis = Basis.looking_at(-target_vector)
		basis = basis.slerp(target_basis, turningSpeed * delta)
		
		#if basis.get_scale().snapped(Vector3(0.01, 0.01, 0.01)) == target_basis.get_scale().snapped(Vector3(0.01, 0.01, 0.01)):
		if basis.is_equal_approx(target_basis):
			return true
		else:
			return false

func shoot(times):
		for i in range(times):
			# guns.addedVar = 0.0

			if guns.canShoot:
				guns.shoot()


func updatePredictionReticle():
	if predictionReticle:
		# var player_position = player.global_position
		# var player_velocity = player.linear_velocity

		# Calculate the time it takes for the projectile to reach the target
		var distance_to_player = global_position.distance_to(player.global_position)

		var time_to_impact = distance_to_player / playerGuns.bulletSpeed

		# Calculate the predicted position of the target
		var predicted_position = global_position + velocity * time_to_impact

		# Set the position of the leading indicator
		predictionReticle.global_position = predicted_position

		# if velocity.length() > playerGuns.bulletSpeed/100 and player.updatePredictionReticle:
		# 	var time_to_impact = distance_to_player / playerGuns.bulletSpeed

		# 	# Calculate the predicted position of the target
		# 	var predicted_position = global_position + velocity * time_to_impact

		# 	# Set the position of the leading indicator
		# 	predictionReticle.global_position = predicted_position

		# 	predictionReticle.visible = true
		# else:
		# 	predictionReticle.visible = false



func hit(damage):
	if state != "dead":
		if healthData.shield > 0:
			healthData.setShield(healthData.shield - damage)
		else:
			healthData.setHealth(healthData.health - damage)

		
		if healthData.health <= 0:
			collider.disabled = true
			mesh.visible = false
			die()

func updateHealth():
	healthbar.max_value = healthData.maxHealth
	healthbar.value = healthData.health

	shieldbar.max_value = healthData.maxShield
	shieldbar.value = healthData.shield


func die():
	state = "dead"
	velocity = Vector3.ZERO
	mesh.visible = false
	collider.disabled = true
	collider.get_shape().size = Vector3.ZERO

	if player.lockedTarget:
		if player.lockedTarget.collider == self:
			player.targetLocked = false
			player.lockedTarget = null

	# print(state)

	# collider.visible = false	
	# mesh.visible = false


	var explosion = explode.instantiate()
	add_child(explosion)

	var random = randi_range(0, drops.size()-1)
	var collectible = drops[random].instantiate()
	root.add_child(collectible)
	collectible.global_position = explosion.global_position

	await get_tree().create_timer(3.5).timeout
	queue_free()
	print(self, "is gone. forever")
	

func random_point_in_sphere_surface(target, radius) -> Vector3:
	var random_direction = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	return target + random_direction * radius
