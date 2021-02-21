tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("WaterBody", "Spatial", preload("res://addons/ocean/scripts/WaterBody.gd"), preload("res://addons/ocean/textures/WaterBodyIcon.png"))
	pass


func _exit_tree():
	remove_custom_type("WaterBody")
	pass
