extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = get_viewport().size.x / 2
	position.y = get_viewport().size.y / 2
	pass # Replace with function body.

# warning-ignore:unused_argument
func _process(delta):
	position.x = get_viewport().size.x / 2
	position.y = get_viewport().size.y / 2
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
