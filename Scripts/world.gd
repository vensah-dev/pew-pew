extends Node3D

@onready var player = $"../player"

var celestialBodies

func _ready():
	await get_tree().process_frame
	celestialBodies = get_tree().get_nodes_in_group("CelestialBody")

	for b in celestialBodies:
		b.actualPosition = b.rigidbody.global_position


func _process(_delta):
	
	
	var originOffset = player.global_position
	# var dstFromOrigin = originOffset.distance_to(Vector3(0, 0, 0))

	global_position -= originOffset
	player.global_position = Vector3(0, 0, 0)

	player.actualPosition += originOffset

	for b in celestialBodies:
		if is_instance_valid(b):
			b.actualPosition = b.rigidbody.global_position + player.actualPosition


	# for b in celestialBodies:
	# 	b.actualPosition -= originOffset



	# print("player position: ", player.actualPosition)


	# Print the vertex count to the console for debugging
	# print("Vertex count: ", str(RenderingServer.viewport_get_render_info(%SubViewport.get_viewport_rid(), RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME)) )




	
