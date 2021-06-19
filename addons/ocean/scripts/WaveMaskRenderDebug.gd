
extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var MaskViewport : NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	material_override.albedo_texture = (get_node(MaskViewport).get_texture())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
