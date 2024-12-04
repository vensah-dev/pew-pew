extends Node3D

@export var speed = 40
@export var despawnRange = 5000

@onready var player = get_tree().get_nodes_in_group("playerNode")[0]

@onready var rayCast = $RayCast3D
@onready var impact = $impact
@onready var sound = $sound

var damage

func _ready():
	scale = Vector3(0.1, 0.1, 0.5)
	sound.play()

func _process(delta):
	position += transform.basis * Vector3(0, 0, speed) * delta

	if global_position.distance_to(player.global_position) > despawnRange:	
		queue_free()

func _physics_process(_delta: float) -> void:
	if rayCast.is_colliding():
		var collided_object = rayCast.get_collider()  
		if collided_object.is_in_group("enemy"):
			collided_object.hit(damage)

		# if collided_object.is_in_group("enemy"):
		# 	collided_object.get_child(0).health -= 5

		# 	if collided_object.get_child(0).health <= 0:
		# 		collided_object.die()

		rayCast.visible = false
		impact.emitting = true
		await get_tree().create_timer(1.0).timeout
		self.queue_free()
