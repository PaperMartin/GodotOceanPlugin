tool
extends Spatial

export var HorizontalSubdivision : int = 5 setget _horizontalsubdivisionupdate
export var VerticalSubdivision : int = 5 setget _verticalsubdivisionupdate
export var QuadSize : Vector2 setget _setquadsize
export (Resource) var Wave1 setget _updatevar
export var WaterMaterial : ShaderMaterial setget _set_material

var _waterMesh : MeshInstance

func _ready():
	InitializeWaterBody()
	if Engine.editor_hint:
		_editor_update()
	pass

func InitializeWaterBody():
	_get_water_mesh()
	pass

func _updatevar(Wave):
	Wave1 = Wave
	if Engine.editor_hint:
		_editor_update()

func _process(delta):
	pass

func _verticalsubdivisionupdate(var subdiv : int):
	VerticalSubdivision = subdiv
	_get_water_mesh().mesh.subdivide_depth = VerticalSubdivision

func _horizontalsubdivisionupdate(var subdiv : int):
	HorizontalSubdivision = subdiv
	_get_water_mesh().mesh.subdivide_width = HorizontalSubdivision

func _setquadsize(var size : Vector2):
	_get_water_mesh().mesh.size = size
	QuadSize = size

func _get_water_mesh():
	if _waterMesh == null:
		_waterMesh = get_node_or_null("WaterMesh")
		if _waterMesh == null:
			_initialize_water_mesh()
	return _waterMesh

func _initialize_water_mesh():
	_waterMesh = MeshInstance.new()
	_waterMesh.set_script(preload("res://addons/ocean/scripts/WaterMesh.gd"))
	_waterMesh.name = "WaterMesh"
	add_child(_waterMesh)
	_waterMesh.owner = self
	_waterMesh.translation = Vector3.ZERO
	var mesh : PlaneMesh = PlaneMesh.new()
	mesh.subdivide_depth = VerticalSubdivision
	mesh.subdivide_width = HorizontalSubdivision
	mesh.size = QuadSize
	_waterMesh.mesh = mesh
	if WaterMaterial != null:
		_set_material(WaterMaterial);

func _set_material(var newMaterial):
	WaterMaterial = newMaterial
	if newMaterial != null:
		var material : ShaderMaterial = WaterMaterial.duplicate()
		_waterMesh.material_override = material
		var Wave1param : Plane = Plane(Wave1.WaveLength,Wave1.Steepness,Wave1.Direction.x,Wave1.Direction.y)
		material.set_shader_param("Wave1", Wave1param)
	else: 
		_waterMesh.material_override = null;

func _editor_update():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
