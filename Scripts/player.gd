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
@export var boostFOVMultiplier = 1.33333333
var boostFOV = normalFOV * boostFOVMultiplier
@export var fovDamping = 2.5 
var currentFOV = 75.0
@export var cameraDamping = 2.5

@export_subgroup("camera shake")
@export var traumaIntensity = 0.25
@export var decay = 1.0 # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(5, 5)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.2  # Maximum rotation in radians (use sparingly).
@export var canvasShakeMultiplier = 2.0

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

@onready var noise = FastNoiseLite.new()
var noise_y = 0

@export_group("Raycast")
@export var raycastRange = 1000
@export var targetMarkerCurve:Curve
@export var targetMarkerNormalColour: Color
@export var targetMarkerLockedColour: Color


@export_group("Health")
@export var healthbar: Node
@export var shieldbar: Node

@export var regenPerUnit = 0.02
@export var timeToRegenAfterHit = 5.0


@export_group("Guns")
@export var listOfGuns: Array[Node]

@onready var vw = DisplayServer.window_get_size()

@onready var canvasNode:CanvasLayer = $"../UI"


@export_group("UI")
@export_subgroup("vignette")

@export var normalVignetteColor:Color = Color(0, 0, 0)
@export var damageVignetteColor:Color = Color(1, 0, 0)
var currentVignetteColor = normalVignetteColor
# @export var interactionKey: StringName

@onready var camGimbal = $cameraGimbal
@onready var cam = $cameraGimbal/Camera

@onready var world = $"../world"

@onready var ui = $"../UI"
@onready var distanceLabel = $"../UI/distance"
@onready var speedLabel = $"../UI/speed"
@onready var statusRing = $"../UI/statusRing"
@onready var interactionLabel = $"../UI/interactionLabel"
@onready var vignette = $"../UI/vignette"


@onready var healthData = $healthData

@onready var mesh = $mesh
@onready var targetLockSprite = $mesh/targetLock
@onready var guns = $mesh/weapons
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

var canLockOnTarget = false
var updatePredictionReticle = true


func _ready() -> void:
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	healthData.setHealth(healthData.maxHealth)
	healthData.setShield(healthData.maxShield)

	vignette.get_material().set_shader_parameter("vignette_color", normalVignetteColor) 

	# shieldRegenTimer.timeout.connect(regenShield)
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

########################
#Process functions
########################

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	
	var from = camNode.project_ray_origin(centre)
	var to = from + camNode.project_ray_normal(centre) * raycastRange
	
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	
	var result = space_state.intersect_ray(params)
	distanceLabel.text = ""
	
	# lockedTarget = result

	if result:
		#stuff done for all colliders
		var collider = result.collider
		var hit_origin = collider.global_transform.origin

		# targetLockSprite.scale = Vector3.ONE * max(collider.scale.x, collider.scale.y, collider.scale.z)

		# var distanceM = global_position.distance_to(hit_origin)
		# var distanceKM:float = snappedf(distanceM/1000, 0.001)
		# distanceLabel.text = str(distanceKM) + "KM"

		#stuff done for select colliders, e.g. target lock on enemies, celestial body info
		if collider.is_in_group("enemy"):

			updateTargetMarker(collider)
			targetLockSprite.targetLockSpriteColor = targetMarkerNormalColour

			if Input.is_action_just_pressed("lock") and canLockOnTarget:
				targetLocked = !targetLocked
				if targetLocked:
					lockedTarget = result

			if targetLocked and canLockOnTarget:
				targetLockSprite.targetLockSpriteColor = targetMarkerLockedColour
				targetLockSprite.global_position = lockedTarget.collider.global_transform.origin

			else:
				lockedTarget = null
				targetLockSprite.global_position = hit_origin

		else:
			lockedTarget = null
			targetLocked = false
			targetLockSprite.visible = false

	else:
		#update markers if needed, like for example locked targets
		if targetLocked and canLockOnTarget:
			updateTargetMarker(lockedTarget.collider)
			targetLockSprite.targetLockSpriteColor = targetMarkerLockedColour

			var targetOrigin = lockedTarget.collider.global_transform.origin
			targetLockSprite.global_position = targetOrigin



		else:
			lockedTarget = null
			targetLocked = false
			targetLockSprite.visible = false


	#to allow mouse pointer to be able to exit the window
	mouse(delta)
	
	#put under physics process asap
	move(delta)
	move_and_slide()

	#Camera Follow but.. SMOOTH HEHEHABUTCTUYC EOUBds
	camGimbal.global_transform = camGimbal.global_transform.interpolate_with(global_transform, cameraDamping * delta)

func _process(delta: float) -> void:
	#what do u think nerd
	switchGuns()

	#idiot u spent way too long trynna figure this out, obviously u need to update your ur current forward, right and up vectors and not only once at the start!!!!
	directions()
	
	inputVector.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	inputVector.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
	inputVector.y = Input.get_action_strength("up") - Input.get_action_strength("down")
	
	rollInput = Input.get_axis("roll_left", "roll_right")
	boostInput = Input.get_action_strength("boost")

	inputVector = inputVector.normalized()
	roll = lerpf(roll, rollInput, rollAcceleration * delta)

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		vignette.get_material().set_shader_parameter("vignette_color", damageVignetteColor) 
	else:
		vignette.get_material().set_shader_parameter("vignette_color", normalVignetteColor) 



################################################################################################
################################################################################################



########################
#Camera Shake
########################

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
		
func shake():
	noise_y += 1
	var amount = pow(trauma, trauma_power)

	var shakeRotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y) * randi_range(-1, 1)
	var shakeH_offset = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y) * randi_range(-1, 1)
	var shakeV_offset = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y) * randi_range(-1, 1)

	cam.rotation.z = shakeRotation
	cam.h_offset = shakeH_offset
	cam.v_offset = shakeV_offset

	canvasNode.rotation = shakeRotation * canvasShakeMultiplier
	canvasNode.offset.x = shakeH_offset * canvasShakeMultiplier
	canvasNode.offset.y = shakeV_offset * canvasShakeMultiplier

########################
#Guns and Target stuff
########################

func switchGuns():
	for n in range(1, listOfGuns.size()+1):
		if Input.is_action_just_pressed(str(n)):
			gunIndex = n-1
		
		if listOfGuns[gunIndex].lockOnTarget:
			canLockOnTarget = true
			updatePredictionReticle = false
		else:
			canLockOnTarget = false
			updatePredictionReticle = true

		# if gunIndex == 0:
		# 	updatePredictionReticle = true
		# else:
		# 	updatePredictionReticle = false

		# if gunIndex == 1:
		# 	canLockOnTarget = true
		# else:
		# 	canLockOnTarget = false

	if activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed >= listOfGuns[gunIndex].bulletSpeed:
		for gun in listOfGuns:
			gun.set_process(false)
	else:
		for i in range(listOfGuns.size()):
			if i == gunIndex:
				listOfGuns[i].set_process(true)
			else:
				listOfGuns[i].set_process(false)

func updateTargetMarker(collider):
	var hit_origin = collider.global_transform.origin

	var distanceM = global_position.distance_to(hit_origin)

	# var scaleMultiplier = max(
	# 	collider.get_child(1).get_shape().size.x/mesh.scale.x, 
	# 	collider.get_child(1).get_shape().size.y/mesh.scale.y,
	# 	collider.get_child(1).get_shape().size.z/mesh.scale.z
	# )

	# targetLockSprite.scale = Vector3.ONE * scaleMultiplier/800

	targetLockSprite.distance = distanceM
	
	targetLockSprite.shieldValue = collider.healthData.shield
	targetLockSprite.healthValue = collider.healthData.health


	targetLockSprite.visible = true

########################
#Movement and mouse
########################

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



	speedLabel.text = str(snapped(activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed, 0.1)) + "U/s"

	var quaternionRot = Quaternion.from_euler(Vector3(y * mouseSpeed * delta, -x * mouseSpeed * delta, roll * rollSpeed * delta))
	transform.basis *= Basis(quaternionRot)

	global_position += transform.basis.z * activeForwardSpeed * delta
	global_position += (transform.basis.x * activeStrifeSpeed * delta) + (transform.basis.y * activeHoverSpeed * delta) 



		# guns.set_process(true)
		
	# velocity = 
	
	#ChatGPT sucks, good thing I deleted my account

	
	#camera movement
	cam.fov = lerpf(cam.fov, currentFOV, fovDamping * delta)

########################
#Health related stuff
########################

func hit(damage):

	if trauma < 0.1:
		add_trauma(traumaIntensity)

	if healthData.shield > 0:
		healthData.setShield(healthData.shield - damage)
	else:
		healthData.setHealth(healthData.health - damage)


	healthData.startRegenShield()

func _on_health_node_health_changed(_value:Variant) -> void:
	updateHealth()

func _on_health_data_shield_changed(_value:Variant) -> void:
	updateHealth()

func updateHealth():
	healthbar.max_value = healthData.maxHealth
	healthbar.value = healthData.health

	shieldbar.max_value = healthData.maxShield
	shieldbar.value = healthData.shield

########################
#Interaction AKA F to ...
########################

func showInteractionLabel(text):
	interactionLabel.visible = true
	interactionLabel.text = text

func hideInteractionLabel():
	interactionLabel.visible = false

func isInteractionKeyPressed():
	return Input.is_action_just_pressed("interact")
