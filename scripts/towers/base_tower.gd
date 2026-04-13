# base_tower.gd
class_name BaseTower
extends Node2D

# Core stats — every tower type has these
@export var tower_name: String = "Base Tower"
@export var damage: int = 0
@export var fire_rate: float = 1.0
@export var attack_range: float = 150.0
@export var cost: int = 100

var is_placed: bool = false

func _ready():
    print("Tower placed: ", tower_name, " at ", global_position)

func _draw():
    if is_placed:
        draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 0, 0.15))