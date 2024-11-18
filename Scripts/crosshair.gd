extends CenterContainer

@export var innerRadius = 5.0
@export var innerColor:Color = Color.WHITE
@export var innerThickness = 2.0

@export var outerColor:Color = Color.BLACK
@export var outerThickness = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _draw():
	draw_arc(Vector2(16, 16), innerRadius, 0, 2*PI, 360, innerColor, innerThickness)
	draw_arc(Vector2(16, 16), innerRadius+outerThickness, 0, 2*PI, 360, outerColor, outerThickness)
