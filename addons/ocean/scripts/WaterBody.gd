tool
extends Spatial

export var HorizontalSubdivision : int = 5 setget _horizontalsubdivisionupdate
export var VerticalSubdivision : int = 5 setget _verticalsubdivisionupdate
export var QuadSize : Vector2 setget _setquadsize
export (Resource) var Wave1 setget _updatevar

var _waterMat : Material
var _waterMesh : MeshInstance

func _ready():
	if Engine.editor_hint:
		print_debug("water body initialization")
		InitializeWaterBody()
	pass

func InitializeWaterBody():
	get_water_mesh()
	pass

func _updatevar(Wave):
	Wave1 = Wave
	if Engine.editor_hint:
		_editor_update()

func _process(delta):
	pass

func _verticalsubdivisionupdate(var subdiv : int):
	VerticalSubdivision = subdiv
	get_water_mesh().mesh.subdivide_depth = VerticalSubdivision

func _horizontalsubdivisionupdate(var subdiv : int):
	HorizontalSubdivision = subdiv
	get_water_mesh().mesh.subdivide_width = HorizontalSubdivision

func _setquadsize(var size : Vector2):
	get_water_mesh().mesh.size = size
	QuadSize = size

func get_water_mesh():
	if _waterMesh == null:
		_waterMesh = get_node_or_null("WaterMesh")
		if _waterMesh == null:
			_initialize_water_mesh()
	return _waterMesh

func _initialize_water_mesh():
	_waterMesh = MeshInstance.new()
	_waterMesh.name = "WaterMesh"
	add_child(_waterMesh)
	_waterMesh.owner = self
	_waterMesh.translation = Vector3.ZERO
	var mesh : PlaneMesh = PlaneMesh.new()
	mesh.subdivide_depth = VerticalSubdivision
	mesh.subdivide_width = HorizontalSubdivision
	mesh.size = QuadSize
	_waterMesh.mesh = mesh

func _editor_update():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
