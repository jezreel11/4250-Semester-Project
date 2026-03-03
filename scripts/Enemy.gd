extends PathFollow2D

signal reached_base

@export var speed: float = 100.0

func _process(delta):
	progress += speed * delta

	if progress_ratio >= 1.0:
		emit_signal("reached_base")
		queue_free()
