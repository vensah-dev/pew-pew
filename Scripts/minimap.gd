extends ColorRect

@export var target : NodePath
@export var followTarget : bool = false
@export var cameraDistance := 250.0
@export var keyBind : StringName

@onready var player := get_node(target)
@onready var subViewportContainer := $SubViewportContainer
@onready var subViewport := $SubViewportContainer/SubViewport
@onready var camera := $SubViewportContainer/SubViewport/Camera3D


func _ready() -> void:

	print("self:", self)

	subViewport.size = size
	subViewportContainer.size = size
	subViewportContainer.global_position = global_position

	# print("subViewportContainer", str(subViewportContainer.size))
	# print("subViewport", str(subViewport.size))
	# print("size", str(size))

	# print("subViewportContainer", str(subViewportContainer.position))
	# print("size", str(position))

	if keyBind != "":
		visible = false
	else:
		visible = true


func _process(_delta: float) -> void:

	
	if keyBind != "":
		if Input.is_action_just_pressed(keyBind):
			visible = !visible

	if target:
		camera.size = cameraDistance
		if followTarget:
			camera.position = Vector3(player.position.x, player.position.y + cameraDistance, player.position.z)
		else:
			camera.position = Vector3(0, cameraDistance, 0)
