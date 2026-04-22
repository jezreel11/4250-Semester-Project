extends Node2D

@export var max_health: int = 500
var current_health: int

signal game_over
signal health_changed(current_health: int, max_health: int)

func _ready():
	current_health = max_health
	add_to_group("towers")
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int):
	# Don't take damage if already destroyed
	if current_health <= 0:
		return

	current_health -= amount
	current_health = max(current_health, 0)
	queue_redraw()
	emit_signal("health_changed", current_health, max_health)
	print("Base HP: ", current_health, " / ", max_health)
	if current_health <= 0:
		print("Base destroyed! Game Over!")
		emit_signal("game_over")

func _draw():
	var bar_w = 6.0
	var bar_h = 50.0
	# Offset to center on the house (house is to the right of path end)
	var bar_x = 40.0 - bar_w / 2.0
	var bar_y = -120.0

	# Background
	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15, 0.85))

	# Fill from bottom up
	var fill_h = bar_h * (float(current_health) / float(max_health))
	var fill_y = bar_y + (bar_h - fill_h)
	draw_rect(Rect2(bar_x, fill_y, bar_w, fill_h), Color(0.0, 0.5, 0.0, 1.0))
