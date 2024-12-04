extends Node3D

@export_group("Bullets")
@export var bulletSpeed = 100
@export var bulletRange = 1000
@export var bulletDamage = 5

@onready var Bullet = load("res://Scenes/bullet.tscn")


@export_group("Gun Settings")
@export var automatic = true
@export var reloadInterval = 0.25
@export var pointToCrosshair = true
@export var fireAllGunsAtOnce = false

@export var gunPoints: Array[Node3D]


@onready var main = get_tree().current_scene
@onready var cam = get_viewport().get_camera_3d()

@onready var space = get_world_3d().direct_space_state
@onready var centre = get_viewport().get_visible_rect().size / 2

var sprinting = false
var canShoot = true
	
func _process(_delta):
	var from = cam.project_ray_origin(centre)
	var to = from + cam.project_ray_normal(centre) * bulletRange
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var results = space.intersect_ray(query)
	
	if automatic:
		if Input.is_action_pressed("fire") and canShoot:
			shoot(results)
	else:
		if Input.is_action_just_pressed("fire"):
			shoot(results)

func shoot(results):
	for gun in gunPoints:
		var bullet = Bullet.instantiate()
		
		bullet.global_transform = gun.global_transform
		bullet.speed = bulletSpeed
		bullet.damage = bulletDamage
		bullet.scale = Vector3(1, 1, 1)
		
		# check if the gun need to aim the bullets toward the crosshair or not
		if pointToCrosshair:
			if results:
				if gun.position.distance_to(results.position) > 10:
					bullet.look_at_from_position(gun.global_position, results.position, bullet.basis.y, true)
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
