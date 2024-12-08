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


@export_group("Timer")
@export var timer: Timer

@onready var main = get_tree().current_scene

@onready var space = get_world_3d().direct_space_state
@onready var centre = get_viewport().get_visible_rect().size / 2

var sprinting = false
var canShoot = true

var addedVar = 0.0

var numberOfBullets
	
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

func _process(_delta: float) -> void:
	if isPlayer:
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
			canShoot = false

			numberOfBullets -= 1
			if numberOfBullets > 0:
				await get_tree().create_timer(bulletInterval).timeout
			else:
				await get_tree().create_timer(cooldownInterval).timeout
				numberOfBullets = magSize

			canShoot = true

	if fireAllGunsAtOnce:
		canShoot = false
		
		numberOfBullets -= 1
		if numberOfBullets == 0:
			await get_tree().create_timer(cooldownInterval).timeout
			numberOfBullets = magSize

		canShoot = true
