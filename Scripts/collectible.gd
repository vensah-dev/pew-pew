extends Node3D

@export var collectibleType = "currency"
@export var speedOfAttraction = 10.0
@onready var gameManager = get_tree().get_first_node_in_group("gameManager")
# @onready var player = get_tree().get_first_node_in_group("player")

@onready var player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	look_at(player.global_position, transform.basis.y, true)
	speedOfAttraction += speedOfAttraction*delta
	global_position += transform.basis * Vector3(0, 0, speedOfAttraction) * delta

func _on_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		gameManager.currency += 1
		queue_free()
