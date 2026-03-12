extends Node2D

# Tower base stats — easy to expand later for your upgrade system
@export var tower_name: String = "Basic Tower"
@export var damage: int = 10
@export var fire_rate: float = 1.0  # shots per second
@export var range: float = 150.0

func _ready():
	print("Tower placed: ", tower_name, " at ", global_position)

func _draw():
	# Draws the range circle so you can visually test placement
	draw_circle(Vector2.ZERO, range, Color(1, 1, 1, 0.1))
