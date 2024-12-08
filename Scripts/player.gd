extends CharacterBody3D

@export_group("Speed")
@export var forwardSpeedRange = {"min": 25, "max": 25}; 
@export var strifeSpeed = 7.5;
@export var hoverSpeed = 5.0;
@export var rollSpeed = 5.0;
var forwardSpeed = forwardSpeedRange.min;
@onready var actualPosition = Vector3(0, 0, 0)

@export var boostSpeed = 10.0;

@export_group("Acceleration")
@export var forwardAcceleration = 1.5;
@export var strifeAcceleration = 1.5;
@export var hoverAcceleration = 1.5;
@export var rollAcceleration = 2.5;

@export_group("Mouse")
@export var mouseSpeed = 2.0
@export var mouseDamping = 1.5
@export var mouseIdleThreshold = 0.15

@export_group("Camera")
@export var normalFOV = 75.0
var boostFOV = normalFOV + 50.0
@export var fovDamping = 2.5 
var currentFOV = 75.0

@export_group("Raycast")
@export var raycastRange = 1000
@export var targetMarkerCurve:Curve
@export var targetMarkerNormalColour: Color
@export var targetMarkerLockedColour: Color

@export_group("Health")
@export var healthbar: Node
@export var shieldbar: Node

@export_group("Guns")
@export var listOfGuns: Array[Node]

@onready var vw = DisplayServer.window_get_size()

@onready var cam = $Camera

@onready var world = $"../world"


@onready var distanceLabel = $"../UI/distance"
@onready var speedLabel = $"../UI/speed"

@onready var healthData = $healthData

@onready var mesh = $mesh
@onready var targetLockSprite = $mesh/targetLock
@onready var guns = $mesh/machineGuns
# @onready var trails = $mesh/trails

@onready var camNode = get_viewport().get_camera_3d()
@onready var centre = get_viewport().get_visible_rect().size / 2

var inputVector = Vector3()
var mouseDistance = Vector2()
var mouseButtonLeft
var mouseButtonRight
var mouseButtonMiddle

var rollInput = 0.0
var roll = 0.0

var boostInput = 0.0

var forward = transform.basis.z
var left = transform.basis.x
var up = transform.basis.y

var y = 0
var x = 0

var activeForwardSpeed: float
var activeStrifeSpeed: float
var activeHoverSpeed: float

var gunIndex = 0

var lockedTarget
var targetLocked

var updateTargetLockSprite = false
var updatePredictionReticle = true

func _ready() -> void:
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	# updateHealth()
	healthData.setHealth(healthData.maxHealth)
	healthData.setShield(healthData.maxShield)

	# updateHealth()

	# var trail = GPUTrail3D.new()
	# # trail.length = 50
	# trail.length_seconds = 3
	# trails.add_child(trail)
	# trail.billboard = true

	# # trail.visible = false

func _input(event):
	if event is InputEventMouse:
		mouseDistance.x = (event.global_position.x - (vw.x*0.5))/(vw.y*0.5)
		mouseDistance.y = (event.global_position.y - (vw.y*0.5))/(vw.y*0.5)
		
		mouseDistance = mouseDistance.clamp(Vector2(-1, -1), Vector2(1, 1))


func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	
	var from = camNode.project_ray_origin(centre)
	var to = from + camNode.project_ray_normal(centre) * raycastRange
	
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	
	#var targetPos = global_transform.origin * Vector3.FORWARD * raycastRange
	#
	#var params = PhysicsRayQueryParameters3D.new()
	#params.from = global_transform.origin
	#params.to = targetPos
	#params.exclude = []
	
	var result = space_state.intersect_ray(params)
	distanceLabel.text = ""
	
	# lockedTarget = result

	if result:
		var collider = result.collider
		var hit_origin = collider.global_transform.origin

		# targetLockSprite.scale = Vector3.ONE * max(collider.scale.x, collider.scale.y, collider.scale.z)

		var distanceM = global_position.distance_to(hit_origin)
		var distanceKM:float = snappedf(distanceM/1000, 0.001)
		distanceLabel.text = str(distanceKM) + "KM"

		if collider.is_in_group("enemy") and updateTargetLockSprite:

			var scaleMultiplier = max(
				collider.get_child(1).get_shape().size.x/mesh.scale.x, 
				collider.get_child(1).get_shape().size.y/mesh.scale.y,
				collider.get_child(1).get_shape().size.z/mesh.scale.z
			)

			targetLockSprite.scale = Vector3.ONE * scaleMultiplier/800
			targetLockSprite.visible = true
			targetLockSprite.modulate = targetMarkerNormalColour

			if Input.is_action_just_pressed("lock"):
				targetLocked = !targetLocked

			if targetLocked:
				lockedTarget = result
				targetLockSprite.modulate = targetMarkerLockedColour
				targetLockSprite.global_position = lockedTarget.collider.global_transform.origin

			else:
				lockedTarget = null
				targetLockSprite.global_position = hit_origin

		else:
			lockedTarget = null
			targetLocked = false

	else:
		if targetLocked and updateTargetLockSprite:
			var scaleMultiplier = max(
				lockedTarget.collider.get_child(1).get_shape().size.x/mesh.scale.x, 
				lockedTarget.collider.get_child(1).get_shape().size.y/mesh.scale.y,
				lockedTarget.collider.get_child(1).get_shape().size.z/mesh.scale.z
			)

			targetLockSprite.scale = Vector3.ONE * scaleMultiplier/800

			var targetOrigin = lockedTarget.collider.global_transform.origin
			targetLockSprite.global_position = targetOrigin

			targetLockSprite.modulate = targetMarkerLockedColour
			targetLockSprite.visible = true

		else:
			lockedTarget = null
			targetLocked = false
			targetLockSprite.visible = false

	#put under physics process asap
	move(delta)
	move_and_slide()
	
func _process(delta: float) -> void:
	#what do u think nerd
	switchGuns()
	
	#to allow mouse pointer to be able to exit the window
	mouse(delta)
	
	#idiot u spent way too long trynna figure this out, obviously u need to update your ur current forward, right and up vectors and not only once at the start!!!!
	directions()
	
	inputVector.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	inputVector.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
	inputVector.y = Input.get_action_strength("up") - Input.get_action_strength("down")
	
	rollInput = Input.get_axis("roll_left", "roll_right")
	boostInput = Input.get_action_strength("boost")

	inputVector = inputVector.normalized()
	roll = lerpf(roll, rollInput, rollAcceleration * delta)
	

func move(delta):
	#State Handling
		
	if boostInput and inputVector.z > 0:
		currentFOV = boostFOV
		activeForwardSpeed = lerp(activeForwardSpeed, inputVector.z * forwardSpeed * boostSpeed, forwardAcceleration * delta)
		# inputVector *= Vector3(boostSpeed, boostSpeed, boostSpeed)

	else:
		currentFOV = normalFOV
		activeForwardSpeed = lerp(activeForwardSpeed, inputVector.z * forwardSpeed, forwardAcceleration * delta)

	activeStrifeSpeed = lerp(activeStrifeSpeed, inputVector.x * strifeSpeed, strifeAcceleration * delta)
	activeHoverSpeed = lerp(activeHoverSpeed, inputVector.y * hoverSpeed, hoverAcceleration * delta)

	speedLabel.text = str(int(activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed)) + "U/s"


	global_position += transform.basis.z * activeForwardSpeed * delta
	global_position += (transform.basis.x * activeStrifeSpeed * delta) + (transform.basis.y * activeHoverSpeed * delta) 



		# guns.set_process(true)
		
	# velocity = 
	
	#ChatGPT sucks, good thing I deleted my account
	var quaternionRot = Quaternion.from_euler(Vector3(y * mouseSpeed * delta, -x * mouseSpeed * delta, roll * rollSpeed * delta))
	transform.basis *= Basis(quaternionRot)
	
	#camera movement
	cam.fov = lerpf(cam.fov, currentFOV, fovDamping * delta)

func switchGuns():
	for n in range(1, listOfGuns.size()+1):
		if Input.is_action_just_pressed(str(n)):
			gunIndex = n-1

		if gunIndex == 0:
			updatePredictionReticle = true
		else:
			updatePredictionReticle = false

		if gunIndex == 1:
			updateTargetLockSprite = true
		else:
			updateTargetLockSprite = false

	if activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed > forwardSpeed:
		for gun in listOfGuns:
			gun.set_process(false)
	else:
		for i in range(listOfGuns.size()):
			if i == gunIndex:
				listOfGuns[i].set_process(true)
			else:
				listOfGuns[i].set_process(false)

func mouse(delta):
	if Input.get_action_strength("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		
	#mouse damping and to make sure the spaceship can actually stay still when the mouse pointer is rough;y in the middle
	if absf(mouseDistance.y) > mouseIdleThreshold*(vw.y/vw.y):
		y = mouseDistance.y
	else:
		y = lerpf(y, 0, mouseDamping * delta)
		
	if absf(mouseDistance.x) > mouseIdleThreshold*(vw.x/vw.y):
		x = mouseDistance.x
	else:
		x = lerpf(x, 0, mouseDamping * delta)
		
	mouseButtonLeft = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	mouseButtonRight = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	mouseButtonMiddle = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	
func directions():
	forward = transform.basis.z
	left = transform.basis.x
	up = transform.basis.y

func hit(damage):
	if healthData.shield > 0:
		healthData.setShield(healthData.shield - damage)
	else:
		healthData.setHealth(healthData.health - damage)


func _on_health_node_health_changed(_value:Variant) -> void:
	updateHealth()

func _on_health_data_shield_changed(_value:Variant) -> void:
	updateHealth()

func updateHealth():
	healthbar.max_value = healthData.maxHealth
	healthbar.value = healthData.health

	shieldbar.max_value = healthData.maxShield
	shieldbar.value = healthData.shield
