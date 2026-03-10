extends PathFollow2D


@export var speed : float = 80.0

func _process(delta):
	progress += speed * delta
	if progress_ratio >= 1.0:
		preload("res://assets/Animations/LancerAttacking.tscn")
		
