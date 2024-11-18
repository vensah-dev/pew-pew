extends Node3D

@export var speed = 40

func _ready():
	scale = Vector3(0.1, 0.1, 0.5)

func _process(delta):
	position += transform.basis * Vector3(0, 0, speed) * delta
	
	await get_tree().create_timer(5).timeout
	queue_free()
