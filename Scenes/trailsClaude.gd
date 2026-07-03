extends Node3D

@export var trail_length := 40
@export var trail_width := 0.3

var points: Array[Vector3] = []
var mesh_instance: MeshInstance3D
var immediate_mesh: ImmediateMesh

func _ready():
    immediate_mesh = ImmediateMesh.new()
    mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = immediate_mesh
    add_child(mesh_instance)
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.6, 1.0)
    mat.emission_enabled = true
    mat.emission = Color(0.2, 0.6, 1.0)
    mat.emission_energy = 2.0
    mat.vertex_color_use_as_albedo = true
    mesh_instance.material_override = mat

func _process(_delta):
    # Record position (in world space)
    points.push_front(global_position)
    if points.size() > trail_length:
        points.pop_back()
    
    _rebuild_mesh()

func _rebuild_mesh():
    immediate_mesh.clear_surfaces()
    if points.size() < 2:
        return
    
    immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
    
    for i in range(points.size()):
        var t = float(i) / float(points.size() - 1)
        var alpha = 1.0 - t  # fade toward tail
        
        # Get direction along trail to build perpendicular width
        var dir: Vector3
        if i == 0:
            dir = (points[0] - points[1]).normalized()
        elif i == points.size() - 1:
            dir = (points[i - 1] - points[i]).normalized()
        else:
            dir = (points[i - 1] - points[i + 1]).normalized()
        
        # Perpendicular axis (cross with up to get width direction)
        var up = Vector3.UP
        if abs(dir.dot(up)) > 0.99:
            up = Vector3.RIGHT
        var perp = dir.cross(up).normalized() * trail_width * alpha
        
        immediate_mesh.surface_set_color(Color(0.4, 0.8, 1.0, alpha))
        immediate_mesh.surface_add_vertex(points[i] - perp)
        immediate_mesh.surface_set_color(Color(0.4, 0.8, 1.0, alpha))
        immediate_mesh.surface_add_vertex(points[i] + perp)
    
    immediate_mesh.surface_end()