tool
class_name WaveSettings, "res://addons/ocean/textures/WaterBodyIcon.png"
extends Resource

export (float,0.001,999999) var WaveLength setget _set_wavelength
export (float,0,1) var Steepness setget _set_steepness
export var Direction : Vector2 setget _set_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_wavelength(var newWaveLength : float):
	WaveLength = newWaveLength
	emit_signal("changed")

func _set_steepness(var newSteepness : float):
	Steepness = newSteepness
	emit_signal("changed")

func _set_direction(var newDirection : Vector2):
	Direction = newDirection
	emit_signal("changed")

func get_parameters_as_plane():
	var plane : Plane = Plane(WaveLength,Steepness,Direction.x,Direction.y)
	return plane
