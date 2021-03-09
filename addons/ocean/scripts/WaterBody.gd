tool
class_name WaterBody, "res://addons/ocean/textures/WaterBodyIcon.png"
extends Spatial

export var HorizontalSubdivision : int = 49 setget _horizontalsubdivisionupdate
export var VerticalSubdivision : int = 49 setget _verticalsubdivisionupdate
export var QuadSize : Vector2 = Vector2(10,10) setget _setplanesize
export (Resource) var Wave1 = preload("res://addons/ocean/example/WaveSettings/Wave1.tres") setget _update_wave1
export (Resource) var Wave2 = preload("res://addons/ocean/example/WaveSettings/Wave2.tres") setget _update_wave2
export (Resource) var Wave3 = preload("res://addons/ocean/example/WaveSettings/Wave3.tres") setget _update_wave3
export (Resource) var Wave4 = preload("res://addons/ocean/example/WaveSettings/Wave4.tres") setget _update_wave4
export var WaterMaterial : ShaderMaterial = preload("res://addons/ocean/Materials/water_gertsner_default.tres") setget _set_material

signal subdiv_update
signal planesize_update
signal wave1_update
signal wave2_update
signal wave3_update
signal wave4_update
signal material_update

func _ready():
	if Engine.editor_hint:
		_editor_update()
	pass

func _update_wave1(Wave):
	Wave1 = Wave
	emit_signal("wave1_update")
	
func _update_wave2(Wave):
	Wave2 = Wave
	emit_signal("wave2_update")

func _update_wave3(Wave):
	Wave3 = Wave
	emit_signal("wave3_update")

func _update_wave4(Wave):
	Wave4= Wave
	emit_signal("wave4_update")

func _process(delta):
	if Engine.editor_hint:
		_editor_update()

func _verticalsubdivisionupdate(var subdiv : int):
	VerticalSubdivision = subdiv
	emit_signal("subdiv_update")

func _horizontalsubdivisionupdate(var subdiv : int):
	HorizontalSubdivision = subdiv
	emit_signal("subdiv_update")

func _setplanesize(var size : Vector2):
	QuadSize = size
	emit_signal("planesize_update")

func _set_material(var newMaterial):
	WaterMaterial = newMaterial
	emit_signal("material_update")

func _editor_update():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
