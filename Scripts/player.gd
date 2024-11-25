extends CharacterBody3D

@export_group("Speed")
@export var forwardSpeedRange = {"min": 5000, "max": 500};
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
var boostFOV = normalFOV + 25.0
@export var fovDamping = 2.5
var currentFOV = 75.0

@export_group("Raycast")
@export var raycastRange = 1000

@onready var vw = DisplayServer.window_get_size()

@onready var cam = $Camera
@onready var guns = $Lo_poly_Spaceship_01_by_Liz_Reddington2/Guns
@onready var world = $"../world"
@onready var distanceLabel = $"../UI/distance"
@onready var speedLabel = $"../UI/speed"


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

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event):
	if event is InputEventMouse:
		mouseDistance.x = (event.global_position.x - (vw.x*0.5))/(vw.x*0.5)
		mouseDistance.y = (event.global_position.y - (vw.y*0.5))/(vw.x*0.5)
		
		mouseDistance = mouseDistance.clamp(Vector2(-1, -1), Vector2(1, 1))

func _physics_process(_delta):
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
		
	if result:
		var hit_origin = result.collider.global_transform.origin
		var distanceM = global_position.distance_to(hit_origin)
		var distanceKM:float = snappedf(distanceM/1000, 0.001)
		distanceLabel.text = str(distanceKM) + "KM"
	
func _process(delta):
	
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
	
	move(delta)
	move_and_slide()
	speedLabel.text = str(int(velocity.length())) + "U/s"
	

func move(delta):
	#State Handling
		
	if boostInput and inputVector.z > 0:
		currentFOV = boostFOV
		inputVector *= Vector3(boostSpeed, boostSpeed, boostSpeed)
		guns.set_process(false)
		
		
	elif inputVector != Vector3.ZERO:
		currentFOV = normalFOV
		guns.set_process(true)

	else:
		currentFOV = normalFOV
		guns.set_process(true)
		
	velocity = velocity.lerp(forward * inputVector.z * forwardSpeed, forwardAcceleration * delta)
	velocity = velocity.lerp(left * inputVector.x * strifeSpeed, strifeAcceleration * delta)
	velocity = velocity.lerp(up * inputVector.y * hoverSpeed, hoverAcceleration * delta)
	
	#ChatGPT sucks, good thing I deleted my account
	var quaternionRot = Quaternion.from_euler(Vector3(y * mouseSpeed * delta, -x * mouseSpeed * delta, roll * rollSpeed * delta))
	transform.basis *= Basis(quaternionRot)
	
	#camera movement
	cam.fov = lerpf(cam.fov, currentFOV, fovDamping * delta)

func mouse(delta):
	if Input.get_action_strength("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		
	#mouse damping and to make sure the spaceship can actually stay still when the mouse pointer is rough;y in the middle
	if absf(mouseDistance.y) > mouseIdleThreshold:
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
