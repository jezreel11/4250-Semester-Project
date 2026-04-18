extends Node2D

var target: Node2D = null
var damage: int = 10
var speed: float = 250.0

func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return

	var dir = (target.global_position - global_position).normalized()
	global_position += dir * speed * delta

	if global_position.distance_to(target.global_position) < 8.0:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 4.0, Color(1, 0.3, 0, 1))
