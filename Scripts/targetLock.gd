@tool
extends Sprite3D

@export var targetLockSpriteColor: Color = Color(1, 1, 1, 1)

@export var distance: float = 0.0

@export_group("Status Bars")
@export var shieldBarColor: Color = Color(1, 1, 1, 1)
@export var shieldValue: float = 0.0

@export var healthBarColor: Color = Color(1, 1, 1, 1)
@export var healthValue: float = 0.0

@onready var targetLockSprite = $SubViewport/targetLockSprite
@onready var distanceLabel = $SubViewport/VBoxContainer/distanceLabel

@onready var shieldbar = $SubViewport/VBoxContainer/shieldbar
@onready var healthbar = $SubViewport/VBoxContainer/healthbar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	shieldbar.value = shieldValue
	healthbar.value = healthValue
	distanceLabel.text = str(snapped(distance, 0.1))+"m"
	targetLockSprite.modulate = targetLockSpriteColor
