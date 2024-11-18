extends Node3D

@export var distanceThreshold = 10000.0

@onready var player = $"../player"

func _process(_delta):
	
	var originOffset = player.global_position
	var dstFromOrigin = originOffset.distance_to(Vector3(0, 0, 0))

	if dstFromOrigin > distanceThreshold:
		global_position -= originOffset
		player.global_position = Vector3(0, 0, 0)
