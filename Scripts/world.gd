extends Node3D

@onready var player = $"../player"

func _process(_delta):
	
	var originOffset = player.global_position
	# var dstFromOrigin = originOffset.distance_to(Vector3(0, 0, 0))

	global_position -= originOffset
	player.global_position = Vector3(0, 0, 0)
	player.actualPosition += originOffset

	print("player position: ", player.actualPosition)

	
