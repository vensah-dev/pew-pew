extends MarginContainer

@export var playerPath : NodePath
@export var solarSystemSpawnerPath : NodePath
@export var miniMapPath : NodePath

var zoom = 5.0:
	set = set_zoom
var zoomClamp = {"min": 1.0, "max": 100.0};

var zoomStep = 0.1

@export var panSensitivity = 1.0
var panClamp = Vector2()

var keyBind = "gyroscope"

@onready var player := get_node(playerPath)
@onready var solarSystemSpawner = get_node("../../world/Solar System Spawner")
@onready var miniMap = get_node("../minimap")

@onready var contentsBorder = $contentsBorder/contents
@onready var grid = $contentsBorder/contents/grid
@onready var playerMarker = $contentsBorder/contents/grid/player
@onready var starMarker = $contentsBorder/contents/grid/star
@onready var planetMarker = $contentsBorder/contents/grid/planet

@onready var icons = {
	"star": starMarker,
	"greenPlanet": planetMarker,
	"redPlanet": planetMarker,
	"bluePlanet": planetMarker,

}

var worldToMapSize 

var gridScale

var staticMarkers = {}
var staticMarkersPositions = {}

var initialPlayerMarkerScale : Vector2

var panning : bool = false
var dragStartMousePos = Vector2.ZERO
# var tempPlayerMarkerPos = Vector2.ZERO

var minimap = true

func _ready():
	#wait until the scene tree is actually populated before trynna reference something lol
	await get_tree().process_frame

	grid.pivot_offset = grid.size/2

	panClamp.x= grid.size.x/2
	panClamp.y= grid.size.y/2

	worldToMapSize = (solarSystemSpawner.maxSpawnRadius*2)/1000.0

	contentsBorder.clip_contents = true

	initialPlayerMarkerScale = playerMarker.scale

	playerMarker.position = Vector2(grid.size.x / 2, grid.size.y / 2)
	gridScale =  grid.size / (get_viewport_rect().size * worldToMapSize)

	var mapObjects = get_tree().get_nodes_in_group("StaticMinimapItems")

	for item in mapObjects:
		var newMarker = icons[item.type].duplicate()
		grid.add_child(newMarker)
		newMarker.show()
		staticMarkers[item] = newMarker

	for item in staticMarkers:
		var objPos

		objPos = (Vector2(item.rigidbody.global_position.x, item.rigidbody.global_position.z))

		staticMarkersPositions[item] = objPos
	print("staticMarkersPositions: ", staticMarkersPositions)
		
	for item in staticMarkers:

		var pos = (staticMarkersPositions[item] * gridScale + grid.size / 2)

		staticMarkers[item].position = pos

		staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01

		pos = pos.clamp(Vector2.ZERO, grid.size)

	var playerPos = (Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2
	playerMarker.position = playerPos
	
	zoom = 5.0

	visible = false
	
func _process(_delta: float) -> void:

	if keyBind != "":
		if Input.is_action_just_pressed(keyBind):
			visible = !visible

			miniMap.visible = !visible


	if !player:
		return
	
	playerMarker.rotation = player.rotation.y

	#update the godamn zoon 24/7 casue no point trynna actually find out whn to actually do this idc about performance
	grid.scale = Vector2(zoom, zoom)
	
	grid.position.x = clamp(grid.position.x, (-panClamp.x) * (zoom-1), (panClamp.x) * (zoom-1))
	grid.position.y = clamp(grid.position.y, (-panClamp.y) * (zoom-1), (panClamp.y) * (zoom-1))

	playerMarker.scale = initialPlayerMarkerScale/zoom

	#update position
	var playerPos = (Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2
	playerMarker.position = playerPos



#set function
func set_zoom(value):
	zoom = clamp(value, zoomClamp.min, zoomClamp.max)
	print("zoom: ", zoom)
	



#event lol
func _on_gui_input(event: InputEvent) -> void:
	pan()

	scrollToZoom(event)



func pan():
	if !panning and Input.is_action_just_pressed("camera_pan"):
		print("Panning Started")
		dragStartMousePos = get_viewport().get_mouse_position()

		panning = true

	if panning and Input.is_action_just_released("camera_pan"):
		print("Panning Ended")

		panning = false
		
	if panning:
		print("Panning")
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos

		print("zoom inside of panning: ", zoom)
		print("panClamp that is being used: ", (-panClamp.x) * zoom)
		print("panClamp that is being used2: ", panClamp)

		grid.position.x = clamp(grid.position.x + moveVector.x * panSensitivity/zoom, (-panClamp.x) * (zoom-1), (panClamp.x) * (zoom-1))
		grid.position.y = clamp(grid.position.y + moveVector.y * panSensitivity/zoom, (-panClamp.y) * (zoom-1), (panClamp.y) * (zoom-1))

		print("Grid Position: ", grid.position)

func scrollToZoom(event):
	if event is InputEventMouseButton:		
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			print("middle mouse from _unhandled_input")

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			self.zoom += zoomStep * zoom

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			self.zoom -= zoomStep * zoom

