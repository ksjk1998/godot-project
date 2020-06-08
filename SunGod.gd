extends DirectionalLight


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# warning-ignore:unused_argument
func _process(delta):
	rotation.y += 0.01
	rotation.z += 0.01
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
