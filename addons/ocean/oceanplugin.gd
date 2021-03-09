tool
extends EditorPlugin


func _enter_tree():
	#add_custom_type("WaterBody", "Spatial", preload("res://addons/ocean/scripts/WaterBody.gd"), preload("res://addons/ocean/textures/WaterBodyIcon.png"))
	#add_custom_type("SinglePlaneWater", "MeshInstance", preload("res://addons/ocean/scripts/SinglePlaneWater.gd"), preload("res://addons/ocean/textures/WaterBodyIcon.png"))
	#add_custom_type("WaveSettings", "Resource", preload("res://addons/ocean/scripts/WaveSettings.gd"), preload("res://icon.png"))
	pass


func _exit_tree():
	#remove_custom_type("WaterBody")
	#remove_custom_type("SinglePlaneWater")
	#remove_custom_type("WaveSettings")
	pass
