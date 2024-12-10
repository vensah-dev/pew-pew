extends Node3D

@export var ship: Node3D

@export_group("Bullets")
@export var bulletSpeed = 100
@export var bulletRange = 1000
@export var bulletDamage = 5
@export var lockOnTarget = false

@export var bulletNode:PackedScene


@export_group("Gun Settings")
@export var isPlayer : bool = true
@export var automatic = true
@export var bulletInterval = 0.25
@export var magSize = 25
@export var cooldownInterval = 2.5
# @export var pointToCrosshair = false
@export var fireAllGunsAtOnce = false

@export var gunPoints: Array[Node3D]


@export_group("Camera")
@export var cam:Node3D


@export_group("Progress Guage")
@export var idleColor: Color
@export var reloadColor: Color
@export var shootingColor: Color


@onready var main = get_tree().current_scene

@onready var space = get_world_3d().direct_space_state
@onready var centre = get_viewport().get_visible_rect().size / 2

var player

var canShoot = true
var justShot = false

var addedVar = 0.0

var numberOfBullets

var reloading = false

var timer: Timer

# func fire(action:StringName):   

	
# 	if guns.automatic:
# 		if Input.is_action_pressed(action) guns.canShoot:
# 			shoot()
# 	else:
# 		if Input.is_action_just_released(action):
# 			shoot()

func _ready():
	add_to_group("guns")
	numberOfBullets = magSize
	await get_tree().process_frame
	player = get_tree().get_nodes_in_group("player")[0]
	player.progressGuage.max_value = magSize


func _process(_delta: float) -> void:
	if isPlayer:
		if reloading:
			player.progressGuage.fill_mode = 5
			player.progressGuage.tint_progress = reloadColor
			player.progressGuage.max_value = cooldownInterval * 100
			player.progressGuage.value = (cooldownInterval - snapped(timer.time_left, 0.001)) * 100
			print("timeLeft: ", cooldownInterval - snapped(timer.time_left, 0.001))

		else:
			player.progressGuage.fill_mode = 4
			if justShot:
				player.progressGuage.tint_progress = shootingColor
				justShot = false
			else:
				player.progressGuage.tint_progress = idleColor
				
			player.progressGuage.max_value = magSize
			player.progressGuage.value = numberOfBullets

		if automatic:
			if Input.is_action_pressed("fire") and canShoot:
				# guns.addedVar = 0.0

				await shoot()
				# guns.addedVar = 0.0

		else:
			if Input.is_action_just_pressed("fire") and canShoot:
				# guns.addedVar = 0.0

				await shoot()
				# guns.addedVar = 0.0
		
		if Input.is_action_just_pressed("reload") and numberOfBullets < magSize and !reloading:
			await reload()

func shoot():
	for gun in gunPoints:
		# var from = gun.global_position
		# var to = Vector3(gun.global_position.x, gun.global_position.y, gun.global_position.z*bulletRange)
		# var query = PhysicsRayQueryParameters3D.create(from, to)
		# query.exclude = [self]
		
		# results = space.intersect_ray(query)

		var bullet = bulletNode.instantiate()
		
		bullet.global_transform = gun.global_transform
		bullet.scale = Vector3(1, 1, 1)

		bullet.speed = bulletSpeed
		bullet.damage = bulletDamage
		bullet.lockOnTarget = true

		
		if lockOnTarget:
			print("what the ship is locked on: ", ship.lockedTarget)
			if ship.lockedTarget:
				bullet.target = ship.lockedTarget.collider

		# check if the gun need to aim the bullets toward the crosshair or not
		if cam:
			var from = cam.project_ray_origin(centre)
			var to = from + cam.project_ray_normal(centre) * bulletRange
			
			var query = PhysicsRayQueryParameters3D.create(from, to)
			query.exclude = [self]
			
			var results = space.intersect_ray(query)

			if results:
				bullet.look_at_from_position(gun.global_position, results.position, bullet.basis.y, true)
			else:
				bullet.look_at_from_position(gun.global_position, cam.project_position(centre, bulletRange), bullet.basis.y, true)
			# else:
			# 	bullet.look_at_from_position(gun.global_position, gun.global_position * gun.global_transform.basis.z * bulletRange, bullet.basis.y, true)
		

		main.add_child(bullet)

		if !fireAllGunsAtOnce:
			await handleShoot()

	if fireAllGunsAtOnce:
		await handleShoot()


func handleShoot():
	canShoot = false
	justShot = true

	numberOfBullets -= 1
	if numberOfBullets > 0:
		await get_tree().create_timer(bulletInterval).timeout
		canShoot = true
	else:
		await reload()

func reload():
	numberOfBullets = 0
	canShoot = false
	timer = Timer.new()
	timer.wait_time = cooldownInterval
	add_child(timer)
	timer.start()

	reloading = true

	await timer.timeout
	on_timer_timeout()


func on_timer_timeout():
	numberOfBullets = magSize
	canShoot = true

	if isPlayer:
		player.progressGuage.max_value = magSize
		player.progressGuage.value = magSize
		reloading = false
