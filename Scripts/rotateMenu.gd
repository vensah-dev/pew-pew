extends Node3D

@export var rotationSpeed = 0.1

func _process(delta: float) -> void:
    rotate_y(rotationSpeed * delta)
