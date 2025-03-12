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
@export var decay = 1.0 # How quickly the shaking stops [0, 1].
@export var maxRotation = Vector3(15, 15, 15)  # Maximum rotation in radians (use sparingly).
@export var canvasShakeMultiplier = 2.0

@onready var initial_cam_rotation := $cameraGimbal/Camera.rotation_degrees as Vector3

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

@onready var noise = FastNoiseLite.new()
var noise_y = 0

@export_group("Raycast")
@export var raycastRange = 1000
@export var targetMarkerNormalColour: Color
@export var targetMarkerLockedColour: Color


@export_group("Health")
@export var healthbar: Node
@export var shieldbar: Node
@export var immortal: bool = false
# @export var shieldRegenPerUnit = 0.02
# @export var timeToRegenShieldAfterHit = 5.0


@export_group("Guns")
@export var listOfGuns: Array[Node]

@onready var vw = get_viewport().get_visible_rect().size

@onready var canvasNode:CanvasLayer = $"../UI"

@export_group("Die")
@export var explode: PackedScene
@export var gameOverScreen: PackedScene

@export_group("UI")

@export var speedLabel: Node
@export var inventory: Node
@export var statusRing: Node

@export_subgroup("vignette")

@export var normalVignetteColor:Color = Color(0, 0, 0)
@export var damageVignetteColor:Color = Color(1, 0, 0)
@export var regenVignetteColor:Color = Color(1, 0, 0)

var currentVignetteColor = normalVignetteColor
# @export var interactionKey: StringName

@onready var camGimbal = $cameraGimbal
@onready var cam = $cameraGimbal/Camera

@onready var world = $"../world"

@onready var ui = $"../UI"
@onready var distanceLabel = $"../UI/distance"

@onready var interactionLabel = $"../UI/interactionLabel"
@onready var vignette = $"../UI/vignette"

@onready var healthData = $healthData

@onready var mesh = $mesh
@onready var targetLockSprite = $mesh/targetLock
@onready var weapons = $mesh/weapons
@onready var collider = $boxCollider
# @onready var trails = $mesh/trails

@onready var camNode = get_viewport().get_camera_3d()
@onready var centre = get_viewport().get_visible_rect().size / 2
 
@onready var root = get_tree().current_scene

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

var selectedIndex = 0

var lockedTarget
var targetLocked

var canLockOnTarget = false
var updatePredictionReticle = true

var lookingAtInteractable = false

var inventoryItems = []

func _ready() -> void:

	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	healthData.setHealth(healthData.maxHealth)
	healthData.setShield(healthData.maxShield)

	vignette.get_material().set_shader_parameter("vignette_color", normalVignetteColor) 

	inventoryItems.append_array(listOfGuns)
	
	inventory.items = inventoryItems
	inventory.selectedIndex = selectedIndex
	inventory.updateInventory()

	print("inventoryItems: ", inventoryItems)

########################
#Process functions
########################

func _physics_process(delta: float) -> void:
	centre = get_viewport().get_visible_rect().size / 2

	#i truly eonder what this does
	handleRayCast()

	#to allow mouse pointer to be able to exit the window
	mouse(delta)
	
	#put under physics process asap
	move(delta)
	move_and_slide()

	#Camera Follow but.. SMOOTH HEHEHABUTCTUYC EOUBds
	camGimbal.global_transform = camGimbal.global_transform.interpolate_with(global_transform, cameraDamping * delta)

func _process(delta: float) -> void:
	#what do u think nerd
	handleInventory()

	#idiot u spent way too long trynna figure this out, obviously u need to update your ur current forward, right and up vectors and not only once at the start!!!!
	directions()
	
	inputVector.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	inputVector.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
	inputVector.y = Input.get_action_strength("up") - Input.get_action_strength("down")
	
	rollInput = Input.get_axis("roll_left", "roll_right")
	boostInput = Input.get_action_strength("boost")

	inputVector = inputVector.normalized()
	roll = lerpf(roll, rollInput, rollAcceleration * delta)

################################################################################################
################################################################################################

########################
#HandleRayCast like showing the enemy info and stuff like that
########################

func handleRayCast():
	var space_state = get_world_3d().direct_space_state
	
	var from = camNode.project_ray_origin(centre)
	var to = from + camNode.project_ray_normal(get_viewport().get_mouse_position()) * raycastRange
	
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	
	var result = space_state.intersect_ray(params)
	distanceLabel.text = ""
	
	# lockedTarget = result

	if result:
		#stuff done for all colliders
		var targetCollider = result.collider
		var hit_origin = targetCollider.global_transform.origin

		# targetLockSprite.scale = Vector3.ONE * max(target_collider.scale.x, target_collider.scale.y, target_collider.scale.z)

		var distanceM = global_position.distance_to(hit_origin)
		var distanceKM:float = snappedf(distanceM/1000, 0.001)
		distanceLabel.text = str(distanceKM) + "KM"

		#stuff done for select target_colliders, e.g. target lock on enemies, celestial body info
		if targetCollider.is_in_group("enemy"):

			updateTargetMarker(targetCollider)
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

		if targetCollider.is_in_group("shop"):
			lookingAtInteractable = true
			showInteractionLabel("F to open shop")
			if Input.is_action_just_pressed("interact"):
				targetCollider.openShop()

		elif !targetCollider.is_in_group("shop"):
			lookingAtInteractable = false
			hideInteractionLabel()

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

########################
#Inventory stuff
########################

func handleInventory():
	for n in range(1, inventoryItems.size()+1):
		if Input.is_action_just_pressed(str(n)):
			selectedIndex = n-1
			

		# if selectedIndex == 0:
		# 	updatePredictionReticle = true
		# else:
		# 	updatePredictionReticle = false

		# if selectedIndex == 1:
		# 	canLockOnTarget = true
		# else:
		# 	canLockOnTarget = false

	inventory.items = inventoryItems
	inventory.selectedIndex = selectedIndex
	
	for gun in listOfGuns:
		gun.set_process(false)
	#handle gun states
	statusRing.visible = false
	if inventoryItems[selectedIndex].get_class() == "Node3D": #check if its a gun node remeber to change later 
		statusRing.visible = true
		if activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed < inventoryItems[selectedIndex].bulletSpeed:

			inventoryItems[selectedIndex].set_process(true)

			if inventoryItems[selectedIndex].lockOnTarget == true:
				canLockOnTarget = true
				updatePredictionReticle = false
			else:
				canLockOnTarget = false

	elif inventoryItems[selectedIndex].get_class() == "Resource":
		if Input.is_action_just_pressed("interact"):
			inventoryItems[selectedIndex].use()
			inventoryItems.remove_at(selectedIndex)
			selectedIndex -= 1
	print("inventoryItems: ", inventoryItems)
	inventory.updateInventory()

func inventoryFull():
	return inventoryItems.size() == 6

func addItem(item):
		inventoryItems.append(item)
		inventory.updateInventory()

########################
#Target stuff
########################

func updateTargetMarker(targetMarkerCollider):
	var hit_origin = targetMarkerCollider.global_transform.origin

	var distanceM = global_position.distance_to(hit_origin)

	# var scaleMultiplier = max(
	# 	targetMarkerCollider.get_child(1).get_shape().size.x/mesh.scale.x, 
	# 	targetMarkerCollider.get_child(1).get_shape().size.y/mesh.scale.y,
	# 	targetMarkerCollider.get_child(1).get_shape().size.z/mesh.scale.z
	# )

	# targetLockSprite.scale = Vector3.ONE * scaleMultiplier/800

	targetLockSprite.distance = distanceM
	
	targetLockSprite.shieldValue = targetMarkerCollider.healthData.shield
	targetLockSprite.healthValue = targetMarkerCollider.healthData.health


	targetLockSprite.visible = true

########################
#Movement and mouse
########################

func directions():
	forward = transform.basis.z
	left = transform.basis.x
	up = transform.basis.y

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

func _input(event):
	if event is InputEventMouse:
		mouseDistance.x = (event.global_position.x - (vw.x*0.5))/(vw.y*0.5)
		mouseDistance.y = (event.global_position.y - (vw.y*0.5))/(vw.y*0.5)
		
		mouseDistance = mouseDistance.clamp(Vector2(-1, -1), Vector2(1, 1))

func move(delta):
	#State Handling
		
	if boostInput:
		currentFOV = boostFOV
		activeForwardSpeed = lerp(activeForwardSpeed, inputVector.z * forwardSpeed * boostSpeed, forwardAcceleration * delta)
		# inputVector *= Vector3(boostSpeed, boostSpeed, boostSpeed)

	else:
		currentFOV = normalFOV
		activeForwardSpeed = lerp(activeForwardSpeed, inputVector.z * forwardSpeed, forwardAcceleration * delta)

	activeStrifeSpeed = lerp(activeStrifeSpeed, inputVector.x * strifeSpeed, strifeAcceleration * delta)
	activeHoverSpeed = lerp(activeHoverSpeed, inputVector.y * hoverSpeed, hoverAcceleration * delta)



	speedLabel.text = str(snapped(activeForwardSpeed+activeHoverSpeed+activeStrifeSpeed, 0.1)) + "U/s"

	roll = lerpf(roll, rollInput, rollAcceleration * delta)

	#ChatGPT sucks, good thing I deleted my account
	var quaternionRot = Quaternion.from_euler(Vector3(y * mouseSpeed * delta, -x * mouseSpeed * delta, roll * rollSpeed * delta))
	transform.basis *= Basis(quaternionRot)

	global_position += transform.basis.z * activeForwardSpeed * delta
	global_position += (transform.basis.x * activeStrifeSpeed * delta) + (transform.basis.y * activeHoverSpeed * delta) 

	cam.fov = lerpf(cam.fov, currentFOV, fovDamping * delta)

########################
#Health related stuff
########################

func hit(damage, bulletTrauma):
	if !immortal:

		if trauma < 0.1:
			cam.add_trauma(bulletTrauma)

		if healthData.shield > 0:
			healthData.setShield(healthData.shield - damage)
		else:
			healthData.setHealth(healthData.health - damage)

		if(healthData.health <= 0):
			commitDie()

		healthData.startRegenShield()

func _on_health_data_health_changed(_value:Variant) -> void:
	updateHealth()
func _on_health_data_shield_changed(_value:Variant) -> void:
	updateHealth()
func _on_health_data_max_health_changed(_value:Variant) -> void:
	updateHealth()
func _on_health_data_max_shield_changed(_value:Variant) -> void:
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

########################
#Freeze
########################

func freeze(activate):
	if activate:
		for gun in listOfGuns:
			gun.set_process(false)

		set_process(false)
		set_physics_process(false)
	else:
		set_process(true)
		set_physics_process(true)

func commitDie():
	velocity = Vector3.ZERO
	mesh.visible = false
	collider.disabled = true

	if lockedTarget:
		if lockedTarget.collider == self:
			targetLocked = false
			lockedTarget = null

	# print(state)

	# collider.visible = false	
	# mesh.visible = false

	#all the set process falses
	set_process(false)
	set_physics_process(false)

	statusRing.visible = false
	for gun in listOfGuns:
		gun.set_process(false)

	var explosion = explode.instantiate()
	add_child(explosion)

	await get_tree().create_timer(3.5).timeout

	var gameover = gameOverScreen.instantiate()
	root.add_child(gameover)

	gameover.get_child(2).get_child(1).button_up.connect(undie)

	#important
	print(self, "is gone. forever") #prints funny message

func undie():
	# remove gameover scene
	get_tree().get_first_node_in_group("gameover").queue_free()

	velocity = Vector3.ZERO
	mesh.visible = true
	collider.disabled = false

	healthData.setHealth(healthData.maxHealth)
	healthData.setShield(healthData.maxShield)

	set_process(true)
	set_physics_process(true)

	statusRing.visible = true
