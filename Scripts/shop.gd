extends StaticBody3D

@onready var canvas = $canvas
@onready var canvasAnim = $canvas/anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# openShop() # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass


func openShop():
	canvasAnim.play("spawn")
	canvasAnim.advance(0)

func closeShop():
	canvasAnim.play("byebye")
	canvasAnim.advance(0)

func _on_close_pressed() -> void:
	closeShop()
