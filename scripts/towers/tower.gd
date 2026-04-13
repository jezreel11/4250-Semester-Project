class_name CannonTower
extends BaseTower

func _ready():
    tower_name = "Cannon Tower"
    damage = 50
    fire_rate = 0.5
    attack_range = 150.0
    cost = 200
    super._ready()

func _draw():
    draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 1, 0.1))