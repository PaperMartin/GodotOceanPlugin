tool
extends Spatial

export var HorizontalSubdivision : int = 49 setget _horizontalsubdivisionupdate
export var VerticalSubdivision : int = 49 setget _verticalsubdivisionupdate
export var QuadSize : Vector2 = Vector2(10,10) setget _setquadsize
export (Resource) var Wave1 = preload("res://addons/ocean/example/WaveSettings/Wave1.tres") setget _update_wave1
export (Resource) var Wave2 = preload("res://addons/ocean/example/WaveSettings/Wave2.tres") setget _update_wave2
export (Resource) var Wave3 = preload("res://addons/ocean/example/WaveSettings/Wave3.tres") setget _update_wave3
export (Resource) var Wave4 = preload("res://addons/ocean/example/WaveSettings/Wave4.tres") setget _update_wave4
export var WaterMaterial : ShaderMaterial = preload("res://addons/ocean/Materials/water_gertsner_default.tres") setget _set_material

var _waterMesh : MeshInstance

func _ready():
	InitializeWaterBody()
	if Engine.editor_hint:
		_editor_update()
	pass

func InitializeWaterBody():
	print_debug(_get_water_mesh())
	pass

func _update_wave1(Wave):
	_get_water_mesh().set_wave1(Wave)
	Wave1 = Wave
	
func _update_wave2(Wave):
	_get_water_mesh().set_wave2(Wave)
	Wave2 = Wave

func _update_wave3(Wave):
	_get_water_mesh().set_wave3(Wave)
	Wave3 = Wave

func _update_wave4(Wave):
	_get_water_mesh().set_wave4(Wave)
	Wave4= Wave

func _process(delta):
	if Engine.editor_hint:
		_editor_update()

func _verticalsubdivisionupdate(var subdiv : int):
	VerticalSubdivision = subdiv
	_get_water_mesh().set_verticalsubdiv(subdiv)

func _horizontalsubdivisionupdate(var subdiv : int):
	HorizontalSubdivision = subdiv
	_get_water_mesh().set_horizontalsubdiv(subdiv)

func _setquadsize(var size : Vector2):
	QuadSize = size
	_get_water_mesh().set_size(size)

func _get_water_mesh():
	if _waterMesh == null:
		_waterMesh = find_node("WaterMesh")
		if _waterMesh == null:
			_initialize_water_mesh()
	return _waterMesh

func _initialize_water_mesh():
	_waterMesh = MeshInstance.new()
	_waterMesh.set_script(preload("res://addons/ocean/scripts/WaterMesh.gd"))
	_waterMesh.name = "WaterMesh"
	add_child(_waterMesh)
	#_waterMesh.owner = self
	_waterMesh.translation = Vector3.ZERO
	_waterMesh.initialize_mesh()
	_waterMesh.set_verticalsubdiv(VerticalSubdivision)
	_waterMesh.set_horizontalsubdiv(HorizontalSubdivision)
	_waterMesh.set_size(QuadSize)
	if Wave1 != null:
		_waterMesh.set_wave1(Wave1)
	if Wave2 != null:
		_waterMesh.set_wave2(Wave2)
	if Wave3 != null:
		_waterMesh.set_wave3(Wave3)
	if Wave4 != null:
		_waterMesh.set_wave4(Wave4)
	if WaterMaterial != null:
		_waterMesh.set_watermaterial(WaterMaterial)

func _set_material(var newMaterial):
	WaterMaterial = newMaterial
	if newMaterial != null:
		_waterMesh.set_watermaterial(WaterMaterial)
	else: 
		_waterMesh.set_watermaterial(null)

func _editor_update():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
