extends CharacterBody3D

@export var behaviour: Resource
@export var worth: int = 100
@export var powerLevel: int = 1

@export var maxSpeed = 50.0
@export var stoppingDistance = 25.0
@export var attackRadius = 10.0
@export var acceleration = 10.0   
@export var turningSpeed = 2.5
@export var explode:PackedScene
@export var despawnDistance: float = 75000
@export var drops: Array[PackedScene]
@export var aimBoxMultipler = 0.2
# @export_group("UI")
# @export var healthbar:Node
# @export var shieldbar:Node

# @export var enemyIndicator:PackedScene

@export var predictionReticleDisapearDistance = 50

@onready var player

@onready var previousLocation = global_position
@onready var destination = random_point_in_sphere_surface(player.global_position, behaviour.surroundRadius)

@onready var healthData = $healthData
@onready var rayCast = $RayCast3D
@onready var collider = $boxCollider
@onready var main = $main
@onready var guns = get_child(0).get_child(0)
@onready var predictionReticle = $main/predictionReticle
@onready var aimBox: Area3D = $main/aimBox

@onready var root = get_tree().current_scene

@onready var state = behaviour.startState

@onready var gameManager = get_tree().get_first_node_in_group("gameManager")

var playerGuns 

var rng = RandomNumberGenerator.new()

var enemySpawner: Node3D

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
	if player.selectedIndex < player.listOfGuns.size():
		playerGuns = player.listOfGuns[player.selectedIndex]
	else:
		playerGuns = null

	var multiplier = global_position.distance_to(player.global_position) * aimBoxMultipler
	aimBox.get_child(0).shape.size = (Vector3.ONE * multiplier).clamp(collider.shape.size*1.5, Vector3.ONE * multiplier)
	predictionReticle.get_child(0).scale = Vector3.ONE * multiplier * 1.25


	# print("enemy health: ", healthData.health)
	# if healthData.health <= 0 and state != "dead":
	# 	die()

	if global_position.distance_to(player.global_position) >= despawnDistance:
		queue_free()

	else:
		behaviour.behave(self, delta)
				
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

func moveTo(to, delta):
	var moveVector = (to - global_position).normalized()
	velocity = velocity.lerp(moveVector * maxSpeed, delta * acceleration)

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
	if predictionReticle and playerGuns:
		# var player_position = player.global_position
		# var player_velocity = player.linear_velocity

		# Calculate the time it takes for the projectile to reach the target
		var distance_to_player = global_position.distance_to(player.global_position)

		var time_to_impact = distance_to_player / playerGuns.bulletSpeed

		# Calculate the predicted position of the target
		var predicted_position = global_position + velocity * time_to_impact

		# Set the position of the leading indicator
		predictionReticle.global_position = predicted_position

		predictionReticle.visible = true

		# if velocity.length() > playerGuns.bulletSpeed/100 and player.updatePredictionReticle:
		# 	var time_to_impact = distance_to_player / playerGuns.bulletSpeed

		# 	# Calculate the predicted position of the target
		# 	var predicted_position = global_position + velocity * time_to_impact

		# 	# Set the position of the leading indicator
		# 	predictionReticle.global_position = predicted_position

		# else:
	else:
		predictionReticle.visible = false

func hit(damage, _t):
	if state != "dead":
		if healthData.shield > 0:
			healthData.setShield(healthData.shield - damage)
		else:
			healthData.setHealth(healthData.health - damage)

		
		if healthData.health <= 0:
			collider.disabled = true
			main.visible = false
			die()

	healthData.startRegenShield()

func die():
	state = "dead"
	velocity = Vector3.ZERO
	main.visible = false
	aimBox.get_child(0).disabled = true
	collider.disabled = true
	collider.get_shape().size = Vector3.ZERO

	enemySpawner.currentEnemies.erase(self)

	# for i in enemySpawner.currentEnemies.size():
	# 	if enemySpawner.currentEnemies[i] == self:
	# 		enemySpawner.currentEnemies[i].remo

	if player.lockedTarget:
		if player.lockedTarget == self:
			player.targetLocked = false
			player.lockedTarget = null

	# print(state)

	# collider.visible = false	
	# main.visible = false


	var explosion = explode.instantiate()
	add_child(explosion)

	gameManager.currency += worth

	if drops.size() > 0:
		var random = randi_range(0, drops.size()-1)
		var collectible = drops[random].instantiate()
		root.add_child(collectible)
		collectible.global_position = explosion.global_position

	await get_tree().create_timer(3.5).timeout
	queue_free()	

func random_point_in_sphere_surface(target, radius) -> Vector3:
	var random_direction = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	return target + random_direction * radius
