extends Node3D

signal hitTarget

@export var speed = 40
@export var despawnTime = 15.0

@onready var player = get_tree().get_first_node_in_group("player")

@onready var mesh = $mesh
@onready var rayCast = $RayCast3D
@onready var impact = $impact
@onready var impactSound = $impact/impactSound
@onready var sound = $sound

var enemyBullet = false

var damage

var target
var lockOnTarget = false

var startingPos

var bulletRange

var randomPitch 

@onready var currentSpeed = speed

func _ready():
	rayCast.scale = Vector3.ONE * 15
	randomPitch = randf_range(0.9, 1.1)
	scale = Vector3(0.1, 0.1, 0.5)
	sound.pitch_scale *= randomPitch
	sound.play()
	startingPos = global_position


	await get_tree().create_timer(despawnTime).timeout
	queue_free()


func _physics_process(delta: float) -> void:	
	if is_instance_valid(target):
		if global_position.distance_to(target.global_position) > 1:
			look_at(target.global_position, transform.basis.y, true)

		global_position += transform.basis * Vector3(0, 0, currentSpeed) * delta

	else:
		position += transform.basis * Vector3(0, 0, currentSpeed) * delta

	# if global_position.distance_to(player.global_position) > range:	
	# 	queue_free()

	if rayCast.is_colliding():
		var collided_object = rayCast.get_collider()  

		if collided_object.is_in_group("enemy") or collided_object.is_in_group("player"):
			collided_object.hit(damage, 0.25)

		# if collided_object.is_in_group("enemy"):
		# 	collided_object.get_child(0).health -= 5

		# 	if collided_object.get_child(0).health <= 0:
		# 		collided_object.die()
		hit()

	if enemyBullet and global_position.distance_to(player.global_position) < 20:
		currentSpeed = speed/2.0
	else:
		currentSpeed = speed

	if global_position.distance_to(startingPos) > bulletRange:
		self.queue_free()

func hit(explode = false):
		rayCast.enabled = false
		mesh.visible = false
		impact.emitting = true
		
		# impactSound.pitch_scale *= randomPitch
		# impactSound.play()

		if !explode:
			hitTarget.emit()

		await get_tree().create_timer(1.0).timeout
		self.queue_free()
