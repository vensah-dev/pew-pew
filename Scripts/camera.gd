extends Camera3D

@onready var player = get_tree().get_first_node_in_group("player")

@onready var initial_cam_rotation := rotation_degrees as Vector3

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

@onready var noise = FastNoiseLite.new()
var noise_y = 0

func add_trauma(amount):
    trauma = min(trauma + amount, 1.0)
		
func shake():
    noise_y += 1
    var amount = pow(trauma, trauma_power)

    var shakeRotation = Vector3.ZERO
    shakeRotation.z = player.maxRotation.z * amount * noise.get_noise_2d(noise.seed, noise_y) * randi_range(-1, 1)
    shakeRotation.y = player.maxRotation.y * amount * noise.get_noise_2d(noise.seed + 1, noise_y) * randi_range(-1, 1)
    shakeRotation.x = player.maxRotation.x * amount * noise.get_noise_2d(noise.seed + 2, noise_y) * randi_range(-1, 1)

    rotation_degrees.z = initial_cam_rotation.z + shakeRotation.z
    rotation_degrees.y = initial_cam_rotation.y + shakeRotation.y
    rotation_degrees.x = initial_cam_rotation.x + shakeRotation.x

	# canvasNode.rotation = shakeRotation * canvasShakeMultiplier
	# canvasNode.offset.x = shakeH_offset * canvasShakeMultiplier
	# canvasNode.offset.y = shakeV_offset * canvasShakeMultiplier

func _process(delta):
    if trauma:
        trauma = max(trauma - player.decay * delta, 0)
        shake()
        player.vignette.get_material().set_shader_parameter("vignette_color", player.damageVignetteColor) 
    else:
        player.vignette.get_material().set_shader_parameter("vignette_color", player.normalVignetteColor) 


