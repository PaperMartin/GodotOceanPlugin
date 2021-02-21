tool

extends Spatial


export (Resource) var Wave1 setget _updatevar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _updatevar(Wave):
	Wave1 = Wave
	if Engine.editor_hint:
		print("update")

func _process(delta):
	pass

func _editor_update():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
