extends PathFollow2D

@export var speed : float = 80.0

func _process(delta):
	progress += speed * delta
