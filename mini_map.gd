extends MarginContainer

@export var playerPath : NodePath
var zoom = 3000.0:
	set = set_zoom

@onready var player := get_node(playerPath)

@onready var bg = $contents/bg
@onready var playerMarker = $contents/bg/player
@onready var starMarker = $contents/bg/star
@onready var planetMarker = $contents/bg/planet

@onready var icons = {
	"star": starMarker,
	"greenPlanet": planetMarker,
	"redPlanet": planetMarker,
	"bluePlanet": planetMarker,

}

var gridScale
var staticMarkers = {}
var staticMarkersPositions = {}
var tempStaticMarkersPositions = {}

var hovered : bool = false



var panning : bool = false
var dragStartMousePos = Vector2.ZERO
# var panStartPosition = Vector2.ZERO
# var moveVector = Vector2.ZERO

func updateStaticMarkers(offset = Vector2.ZERO):
	for item in staticMarkers:

		var pos = (staticMarkersPositions[item] * gridScale + bg.size / 2) + offset

		staticMarkers[item].position = pos

		staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01

		pos = pos.clamp(Vector2.ZERO, bg.size)

		if bg.get_rect().has_point(pos + bg.position):
			staticMarkers[item].show()
		else:
			staticMarkers[item].hide()

func _ready():
	#wait until the scene tree is actually populated before trynna reference something lol
	await get_tree().process_frame

	playerMarker.position = bg.size / 2
	gridScale =  bg.size / (get_viewport_rect().size * zoom)

	var mapObjects = get_tree().get_nodes_in_group("StaticMinimapItems")

	for item in mapObjects:
		var newMarker = icons[item.type].duplicate()
		bg.add_child(newMarker)
		newMarker.show()
		staticMarkers[item] = newMarker

	for item in staticMarkers:
		var objPos

		objPos = (Vector2(item.rigidbody.global_position.x, item.rigidbody.global_position.z))

		staticMarkersPositions[item] = objPos
	print("staticMarkersPositions: ", staticMarkersPositions)
		
	updateStaticMarkers()


func _process(_delta: float) -> void:

	if !player:
		return
	
	playerMarker.rotation = player.rotation.y
	# var playerPos = (Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + bg.size / 2
	# playerMarker.position = playerPos


#set function
func set_zoom(value):
	zoom = clamp(value, 100.0, 3000.0)
	gridScale = bg.size / (get_viewport_rect().size * zoom)

#event lol
func _on_gui_input(event: InputEvent) -> void:
	# dragToPan(event)

	if !panning and Input.is_action_just_pressed("camera_pan"):
		print("Panning Started")
		dragStartMousePos = get_viewport().get_mouse_position()
		tempStaticMarkersPositions = staticMarkersPositions
		panning = true

	if panning and Input.is_action_just_released("camera_pan"):
		print("Panning Ended")
		panning = false
		
	if panning:
		print("Panning")
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos

		playerMarker.position = playerMarker.position + moveVector * 10/zoom

		updateStaticMarkers(moveVector * 10/zoom)

	if event is InputEventMouseButton:        
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			print("middle mouse from _unhandled_input")

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			self.zoom += 100.0
			updateStaticMarkers()

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			self.zoom -= 100.0
			updateStaticMarkers()

