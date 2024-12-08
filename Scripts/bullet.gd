extends Node3D

@export var speed = 40
@export var despawnTime = 5.0

@onready var player = get_tree().get_nodes_in_group("player")[0]

@onready var mesh = $mesh
@onready var rayCast = $RayCast3D
@onready var impact = $impact
@onready var sound = $sound

var damage

var target
var lockOnTarget = false

func _ready():
	scale = Vector3(0.1, 0.1, 0.5)
	sound.play()
	
	if is_instance_valid(target):
		await get_tree().create_timer(5.0).timeout
		queue_free()


func _process(delta):
	if is_instance_valid(target):
		look_at(target.global_position, transform.basis.y, true)
		global_position += transform.basis * Vector3(0, 0, speed) * delta

	else:
		position += transform.basis * Vector3(0, 0, speed) * delta

	# if global_position.distance_to(player.global_position) > despawnRange:	
	# 	queue_free()

func _physics_process(_delta: float) -> void:
	if rayCast.is_colliding():
		var collided_object = rayCast.get_collider()  

		if collided_object.is_in_group("enemy") or collided_object.is_in_group("player"):
			collided_object.hit(damage)

		# if collided_object.is_in_group("enemy"):
		# 	collided_object.get_child(0).health -= 5

		# 	if collided_object.get_child(0).health <= 0:
		# 		collided_object.die()
		hit()

func hit():
		rayCast.enabled = false
		mesh.visible = false
		impact.emitting = true

		await get_tree().create_timer(1.0).timeout
		self.queue_free()
