extends MarginContainer

@export var playerPath : NodePath
@export var solarSystemSpawnerPath : NodePath

@export var zoom = 5.0:
	set = set_zoom
@export var zoomClamp = {"min": 1.0, "max": 100.0};

@export var zoomStep = 0.1

@export var panSensitivity = 1.0
var panClamp = Vector2()

@export var keyBind = "map"

@onready var miniMapSize = Vector2(500, 500)
@onready var mapSize = Vector2(1000, 1000)


@onready var player := get_node(playerPath)
@onready var solarSystemSpawner = get_node("../../world/Solar System Spawner")

@onready var contentsBorder = $contentsBorder
@onready var contents = $contentsBorder/contents
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
var initialPosition : Vector2

var panning : bool = false
var dragStartMousePos = Vector2.ZERO
# var tempPlayerMarkerPos = Vector2.ZERO

var minimap = true:
	set = set_minimap

func _ready():
	#wait until the scene tree is actually populated before trynna reference something lol
	await get_tree().process_frame

	worldToMapSize = (solarSystemSpawner.maxSpawnRadius*2)/1750.0
	gridScale = grid.size / (Vector2(get_viewport_rect().size.y, get_viewport_rect().size.y) * worldToMapSize) #to make sure the gridscale down as a square

	contents.clip_contents = true

	initialPlayerMarkerScale = playerMarker.scale
	initialPosition = position

	var mapObjects = get_tree().get_nodes_in_group("StaticMinimapItems")

	#set staticMarkers
	for item in mapObjects:
		var newMarker = icons[item.type].duplicate()
		grid.add_child(newMarker)
		newMarker.show()
		staticMarkers[item] = newMarker

	#set staticMarkerPositions
	for item in staticMarkers:
		if is_instance_valid(item):

			var objPos

			objPos = (Vector2(item.rigidbody.global_position.x, item.rigidbody.global_position.z))

			staticMarkersPositions[item] = objPos

	#Update StaticMarkers
	for item in staticMarkers:
		if is_instance_valid(item):

			var pos = ((staticMarkersPositions[item] - Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2)

			staticMarkers[item].position = pos

			staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01

			pos = pos.clamp(Vector2.ZERO, grid.size)
	
		
	set_minimap(true)


	#Debug
	# print("staticMarkersPositions: ", staticMarkersPositions)

	# print("playerMarker.scale: ", playerMarker.scale)

	# print("minimap is true")



func _process(_delta: float) -> void:

	if !player:
		return
	
	playerMarker.rotation = player.rotation.y

	gridScale = grid.size / (Vector2(get_viewport_rect().size.y, get_viewport_rect().size.y) * worldToMapSize) #to make sure the gridscale down as a square

	if keyBind != "":
		if Input.is_action_just_pressed(keyBind):
			minimap = !minimap

	
	for item in staticMarkers:

			var objPos
			if is_instance_valid(item):
				objPos = (Vector2(item.actualPosition.x, item.actualPosition.z))

				staticMarkersPositions[item] = objPos

	if minimap:

		for item in staticMarkers:

			var pos = ((staticMarkersPositions[item] - Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2)

			staticMarkers[item].position = pos

			if is_instance_valid(item):
				staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01
			else:
				staticMarkers[item].scale = Vector2(0, 0)

			pos = pos.clamp(Vector2.ZERO, grid.size)

	else:

		var playerPos = (Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2
		playerMarker.position = playerPos

		for item in staticMarkers:

			var pos = ((staticMarkersPositions[item]) * gridScale + grid.size / 2)

			staticMarkers[item].position = pos

			if is_instance_valid(item):
				staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01
			else:
				staticMarkers[item].scale = Vector2(0, 0)
				
			pos = pos.clamp(Vector2.ZERO, grid.size)

	
	set_zoom(zoom)

	#debug
	# print("playerMarker.scale: ", playerMarker.scale)



func set_minimap(value):
	minimap = value

	if minimap:
		# print("minimap is true")

		position = initialPosition

		size = miniMapSize
		grid.size = miniMapSize - Vector2(
			contentsBorder.get_theme_constant("margin_right") + contentsBorder.get_theme_constant("margin_left"),
			contentsBorder.get_theme_constant("margin_top") + contentsBorder.get_theme_constant("margin_bottom")
		)
		# print("grid.size on mini map vs size: ", grid.size, " vs ", size)

		grid.pivot_offset = grid.size/2

		playerMarker.position = Vector2(grid.size.x / 2, grid.size.y / 2)
		gridScale =  grid.size / (get_viewport_rect().size * worldToMapSize)

		panClamp.x= grid.size.x/2
		panClamp.y= grid.size.y/2

		playerMarker.position = Vector2.ZERO + grid.size / 2

		for item in staticMarkers:
			if is_instance_valid(item):

				var pos = ((staticMarkersPositions[item] - Vector2(player.actualPosition.x, player.actualPosition.z)) * gridScale + grid.size / 2)

				staticMarkers[item].position = pos

				staticMarkers[item].scale = Vector2(item.scale.z, item.scale.z) * gridScale * 0.01

				pos = pos.clamp(Vector2.ZERO, grid.size)

		zoom = 5.0

	else:
		# print("minimap is false")


		size = Vector2(get_viewport_rect().size.y, get_viewport_rect().size.y)
		grid.size = Vector2(get_viewport_rect().size.y, get_viewport_rect().size.y) - Vector2(

			contentsBorder.get_theme_constant("margin_right") + contentsBorder.get_theme_constant("margin_left"),
			contentsBorder.get_theme_constant("margin_top") + contentsBorder.get_theme_constant("margin_bottom")
		)

		# print("grid.size on full map vs size: ", grid.size, " vs ", size)

		grid.pivot_offset = grid.size/2

		panClamp.x= grid.size.x/2
		panClamp.y= grid.size.x/2

		position = Vector2((get_viewport_rect().size.x/2.0) - size.x/2, 0)

		playerMarker.position = Vector2(grid.size.x / 2, grid.size.y / 2)
		gridScale =  grid.size / (get_viewport_rect().size * worldToMapSize)

		zoom = 1.0

	

#set function
func set_zoom(value):
	zoom = clamp(value, zoomClamp.min, zoomClamp.max)
	# print("zoom from set_zoom(): ", zoom)

	grid.scale = Vector2(zoom, zoom)
	
	grid.position.x = clamp(grid.position.x, (-panClamp.x) * (zoom-1), (panClamp.x) * (zoom-1))
	grid.position.y = clamp(grid.position.y, (-panClamp.y) * (zoom-1), (panClamp.y) * (zoom-1))

	playerMarker.scale = initialPlayerMarkerScale/zoom

	# print("playerMarker.scale: ", playerMarker.scale)



#event lol
func _on_gui_input(event: InputEvent) -> void:

	if minimap == false:
		pan()

	scrollToZoom(event)



func pan():
	if !panning and Input.is_action_just_pressed("camera_pan"):
		# print("Panning Started")
		dragStartMousePos = get_viewport().get_mouse_position()

		panning = true

	if panning and Input.is_action_just_released("camera_pan"):
		# print("Panning Ended")

		panning = false
		
	if panning:
		# print("Panning")
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos

		grid.position.x = clamp(grid.position.x + moveVector.x * panSensitivity/zoom, (-panClamp.x) * (zoom-1), (panClamp.x) * (zoom-1))
		grid.position.y = clamp(grid.position.y + moveVector.y * panSensitivity/zoom, (-panClamp.y) * (zoom-1), (panClamp.y) * (zoom-1))

		# print("Grid Position: ", grid.position)



func scrollToZoom(event):
	if event is InputEventMouseButton:		

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			self.zoom += zoomStep * zoom

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			self.zoom -= zoomStep * zoom
