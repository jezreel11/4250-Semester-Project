# archer_tower.gd
class_name ArcherTower
extends BaseTower

# Archer-specific — spawns Archer units
@export var spawn_rate: float = 5.0   # seconds between spawns
@export var max_units: int = 3        # max archers alive at once

func _ready():
    tower_name = "Archer Tower"
    damage = 15
    fire_rate = 2.0
    attack_range = 200.0
    cost = 100
    super._ready()