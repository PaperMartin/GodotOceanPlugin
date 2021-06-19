tool
class_name SinglePlaneWaterMesh, "res://addons/ocean/textures/WaterBodyIcon.png"
extends MeshInstance

var waterBody : WaterBody

var wave1 : WaveSettings
var wave2 : WaveSettings
var wave3 : WaveSettings
var wave4 : WaveSettings

# Called when the node enters the scene tree for the first time.

func _enter_tree():
	waterBody = get_parent() as WaterBody
	print_debug(waterBody)
	if true:
		waterBody.connect("wave1_update",self,"update_wave1")
		waterBody.connect("wave2_update",self,"update_wave2")
		waterBody.connect("wave3_update",self,"update_wave3")
		waterBody.connect("wave4_update",self,"update_wave4")
		waterBody.connect("material_update",self,"update_material")
		waterBody.connect("subdiv_update",self,"update_subdiv")
		waterBody.connect("planesize_update",self,"update_plane_size")
		
		initialize_mesh()
		update_material()
		update_wave1()
		update_wave2()
		update_wave3()
		update_wave4()
		update_subdiv()
		update_plane_size()
		pass

func _exit_tree():
	if waterBody.Wave1 != null:
		waterBody.Wave1.disconnect("changed", self, "update_material")
	if waterBody.Wave2 != null:
		waterBody.Wave2.disconnect("changed", self, "update_material")
	if waterBody.Wave3 != null:
		waterBody.Wave3.disconnect("changed", self, "update_material")
	if waterBody.Wave4 != null:
		waterBody.Wave4.disconnect("changed", self, "update_material")
	pass

func initialize_mesh():
	mesh = PlaneMesh.new()
	mesh.subdivide_depth = waterBody.VerticalSubdivision
	mesh.subdivide_width = waterBody.HorizontalSubdivision
	mesh.size = waterBody.QuadSize

func update_subdiv():
	if mesh != null:
		mesh.subdivide_width = waterBody.HorizontalSubdivision
		mesh.subdivide_depth = waterBody.VerticalSubdivision
	pass

func update_plane_size():
	if mesh != null:
		mesh.size = waterBody.QuadSize

func update_wave1():
	if wave1 != null:
		wave1.disconnect("changed", self, "update_material")
	if waterBody.Wave1 != null:
		wave1 = waterBody.Wave1
		wave1.connect("changed",self, "update_material")
	update_material_params()

func update_wave2():
	if wave2 != null:
		wave2.disconnect("changed", self, "update_material")
	if waterBody.Wave2 != null:
		wave2 = waterBody.Wave2
		wave2.connect("changed",self, "update_material")
	update_material_params()

func update_wave3():
	if wave3 != null:
		wave3.disconnect("changed", self, "update_material")
	if waterBody.Wave3 != null:
		wave3 = waterBody.Wave3
		wave3.connect("changed",self, "update_material")
	update_material_params()

func update_wave4():
	if wave4 != null:
		wave4.disconnect("changed", self, "update_material")
	if waterBody.Wave4 != null:
		wave4 = waterBody.Wave4
		wave4.connect("changed",self, "update_material")
	update_material_params()

func update_material():
	if waterBody.WaterMaterial != null:
		material_override = waterBody.WaterMaterial.duplicate()
		update_material_params()

func update_material_params():
	if wave1 != null:
		material_override.set_shader_param("Wave1", wave1.get_parameters_as_plane())
	if wave2 != null:
		material_override.set_shader_param("Wave2", wave2.get_parameters_as_plane())
	if wave3 != null:
		material_override.set_shader_param("Wave3", wave3.get_parameters_as_plane())
	if wave4 != null:
		material_override.set_shader_param("Wave4", wave4.get_parameters_as_plane())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
