# monastery_tower.gd
class_name MonasteryTower
extends BaseTower

# Monastery-specific — spawns Monks that heal nearby units
@export var spawn_rate: float = 8.0
@export var max_units: int = 2
@export var heal_amount: int = 10

func _ready():
    tower_name = "Monastery"
    damage = 0
    fire_rate = 0.0
    attack_range = 120.0
    cost = 150
    super._ready()