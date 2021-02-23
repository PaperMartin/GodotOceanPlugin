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
		WaterMat.connect("changed", self, "update_material")
	if Wave1 != null:
		Wave1.connect("changed", self, "update_material")
	if Wave2 != null:
		Wave2.connect("changed", self, "update_material")
	if Wave3 != null:
		Wave3.connect("changed", self, "update_material")
	if Wave4 != null:
		Wave4.connect("changed", self, "update_material")

func _exit_tree():
	if WaterMat != null:
		WaterMat.disconnect("changed", self, "update_material")
	if Wave1 != null:
		Wave1.disconnect("changed", self, "update_material")
	if Wave2 != null:
		Wave2.disconnect("changed", self, "update_material")
	if Wave3 != null:
		Wave3.disconnect("changed", self, "update_material")
	if Wave4 != null:
		Wave4.disconnect("changed", self, "update_material")
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

func set_watermaterial(var newMaterial : ShaderMaterial):
	if WaterMat != null:
		WaterMat.disconnect("changed", self, "update_material")
	WaterMat = newMaterial
	WaterMat.connect("changed", self, "update_material")
	pass

func set_wave1(var wave):
	if Wave1 != null:
		Wave1.disconnect("changed", self, "update_material")
	Wave1 = wave
	Wave1.connect("changed",self, "update_material")
	update_material()

func set_wave2(var wave):
	Wave2 = wave
	update_material()

func set_wave3(var wave):
	Wave3 = wave
	update_material()

func set_wave4(var wave):
	Wave4 = wave
	update_material()

func update_material():
	material_override = WaterMat.duplicate()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
