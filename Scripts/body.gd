class_name Body
extends Node3D

@export var size = {"min": 5, "max": 10}
@export var type = "planet"
#@export var visibilityRange = 1000
#@export var lightRange = 250
@export var pivotRotationalSpeed = Vector3(0, 0, 0)
@export var axisRotationalSpeed = Vector3(0, 0, 0)
@export var mass = 100
@export var is_sun = false
@export var appearOnMinimap := true

@onready var rigidbody = $RigidBody3D
#@onready var light = get_node("/RigidBody3D/MeshInstance3D/Light")

@onready var root = get_tree().root.get_child(0)
@onready var player

var actualPosition = Vector3(0, 0, 0)

func _ready():
	if appearOnMinimap:
		add_to_group("StaticMinimapItems")

	add_to_group("CelestialBody")

	player = root.get_child(0)

	await get_tree().process_frame


func _process(_delta):
	rotation_degrees += pivotRotationalSpeed
	rigidbody.rotation_degrees += axisRotationalSpeed

	# print(str(self), position, " | isSun: ", str(is_sun))

	
	#if is_sun and global_position.distance_to(player.global_position) < lightRange:
		#light.look_at(player.position, light.transform.basis.y)
		#print("light exists with up direction of:", light.transform.basis.y)
	#
