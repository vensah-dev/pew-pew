extends Node3D

@export var game : PackedScene = load("res://Scenes/Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("9"):
		SceneSwicther.switchSceneBack()
