# barracks_tower.gd
class_name BarracksTower
extends BaseTower

# Barracks-specific — spawns Warriors (high chance) and Lancers (low chance)
@export var spawn_rate: float = 6.0
@export var max_units: int = 4
@export var warrior_spawn_chance: float = 0.75  # 75% warrior, 25% lancer

func _ready():
    tower_name = "Barracks"
    damage = 0           # tower itself doesn't attack, units do
    fire_rate = 0.0
    attack_range = 100.0
    cost = 150
    super._ready()