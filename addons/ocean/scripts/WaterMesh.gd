tool
extends MeshInstance

var HorizontalSubdiv : int
var VerticalSubdiv : int
var Scale : Vector2
var WaterMat : ShaderMaterial
var Wave1 : Resource
var Wave2 : Resource
var Wave3 : Resource
var Wave4 : Resource
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if WaterMat != null:
		WaterMat.connect("changed", self, "_update_material")
	if Wave1 != null:
		Wave1.connect("changed", self, "_update_material")
	if Wave2 != null:
		Wave2.connect("changed", self, "_update_material")
	if Wave3 != null:
		Wave3.connect("changed", self, "_update_material")
	if Wave4 != null:
		Wave4.connect("changed", self, "_update_material")

func _exit_tree():
	if WaterMat != null:
		WaterMat.disconnect("changed", self, "_update_material")
	if Wave1 != null:
		Wave1.disconnect("changed", self, "_update_material")
	if Wave2 != null:
		Wave2.disconnect("changed", self, "_update_material")
	if Wave3 != null:
		Wave3.disconnect("changed", self, "_update_material")
	if Wave4 != null:
		Wave4.disconnect("changed", self, "_update_material")
	pass

func initialize_mesh():
	mesh = PlaneMesh.new()
	mesh.subdivide_depth = VerticalSubdiv
	mesh.subdivide_width = HorizontalSubdiv

func set_horizontalsubdiv(var subdiv : int):
	if mesh != null:
		mesh.subdivide_width = subdiv
	HorizontalSubdiv = subdiv
	pass

func set_verticalsubdiv(var subdiv : int):
	if mesh != null:
		mesh.subdivide_depth = subdiv
	VerticalSubdiv = subdiv
	pass

func set_size(var size : Vector2):
	if mesh != null:
		mesh.size = size

func set_watermaterial(var newMaterial : ShaderMaterial):
	if WaterMat != null:
		WaterMat.disconnect("changed", self, "_update_material")
	WaterMat = newMaterial
	WaterMat.connect("changed", self, "_update_material")
	_update_material()
	pass

func set_wave1(var wave):
	if Wave1 != null:
		Wave1.disconnect("changed", self, "_update_material")
	if wave != null:
		Wave1 = wave
		Wave1.connect("changed",self, "_update_material")
	_update_material()

func set_wave2(var wave):
	print_debug("wave 2 updated")
	if Wave2 != null:
		Wave2.disconnect("changed", self, "_update_material")
	if wave != null:
		Wave2 = wave
		Wave2.connect("changed",self, "_update_material")
	_update_material()

func set_wave3(var wave):
	print_debug("wave 3 updated")
	if Wave3 != null:
		Wave3.disconnect("changed", self, "_update_material")
	if wave != null:
		Wave3 = wave
		Wave3.connect("changed",self, "_update_material")
	_update_material()

func set_wave4(var wave):
	print_debug("wave 4 updated")
	if Wave4 != null:
		Wave4.disconnect("changed", self, "_update_material")
	if wave != null:
		Wave4 = wave
		Wave4.connect("changed",self, "_update_material")
	_update_material()

func _update_material():
	if WaterMat != null:
		print_debug("Updating Material")
		material_override = WaterMat.duplicate()
		if Wave1 != null:
			material_override.set_shader_param("Wave1", _get_wave_as_plane(Wave1))
		if Wave2 != null:
			material_override.set_shader_param("Wave2", _get_wave_as_plane(Wave2))
		if Wave3 != null:
			material_override.set_shader_param("Wave3", _get_wave_as_plane(Wave3))
		if Wave4 != null:
			material_override.set_shader_param("Wave4", _get_wave_as_plane(Wave4))

func _get_wave_as_plane(var wave):
	var plane : Plane = Plane(wave.WaveLength,wave.Steepness,wave.Direction.x,wave.Direction.y)
	return plane
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
