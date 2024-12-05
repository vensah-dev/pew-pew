extends Node3D

@export_group("Bullets")
@export var bulletSpeed = 100
@export var bulletRange = 1000
@export var bulletDamage = 5

@onready var Bullet = load("res://Scenes/bullet.tscn")


@export_group("Gun Settings")
@export var automatic = true
@export var reloadInterval = 0.25
@export var pointToCrosshair = false
@export var fireAllGunsAtOnce = false

@export var gunPoints: Array[Node3D]

@export_group("Camera")
@export var cam:Node3D

@onready var main = get_tree().current_scene

@onready var space = get_world_3d().direct_space_state
@onready var centre = get_viewport().get_visible_rect().size / 2

var sprinting = false
var canShoot = true
	
# func fire(action:StringName):

	
# 	if guns.automatic:
# 		if Input.is_action_pressed(action) guns.canShoot:
# 			shoot()
# 	else:
# 		if Input.is_action_just_released(action):
# 			shoot()

func shoot():
	for gun in gunPoints:
		# var from = gun.global_position
		# var to = Vector3(gun.global_position.x, gun.global_position.y, gun.global_position.z*bulletRange)
		# var query = PhysicsRayQueryParameters3D.create(from, to)
		# query.exclude = [self]
		
		# results = space.intersect_ray(query)



		var bullet = Bullet.instantiate()
		
		bullet.global_transform = gun.global_transform
		bullet.speed = bulletSpeed
		bullet.damage = bulletDamage
		bullet.scale = Vector3(1, 1, 1)
		
		# check if the gun need to aim the bullets toward the crosshair or not

		if pointToCrosshair:

			var from = cam.project_ray_origin(centre)
			var to = from + cam.project_ray_normal(centre) * bulletRange
			
			var query = PhysicsRayQueryParameters3D.create(from, to)
			query.exclude = [self]
			
			var results = space.intersect_ray(query)

			if results:
				if gun.global_position.distance_to(results.position) > 10:
					bullet.look_at_from_position(gun.global_position, results.position, bullet.basis.y, true)

				elif gun.global_position.distance_to(results.position) > 100:  
					bullet.look_at_from_position(gun.global_position, cam.project_position(centre, 75), bullet.basis.y, true)

				else:
					bullet.look_at_from_position(gun.global_position, cam.project_position(centre, 75), bullet.basis.y, true)
					
			else:
				bullet.look_at_from_position(gun.global_position, cam.project_position(centre, 75), bullet.basis.y, true)

		main.add_child(bullet)

		if !fireAllGunsAtOnce:
			canShoot = false
			await get_tree().create_timer(reloadInterval).timeout
			canShoot = true

	if fireAllGunsAtOnce:
		canShoot = false
		await get_tree().create_timer(reloadInterval).timeout
		canShoot = true
