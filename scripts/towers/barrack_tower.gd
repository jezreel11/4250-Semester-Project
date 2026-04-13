class_name BarracksTower
extends BaseTower

@export var spawn_rate: float = 6.0
@export var max_units: int = 4
@export var warrior_spawn_chance: float = 0.75

var warrior_scene = preload("res://assets/Animations/WarriorRunning.tscn")
var lancer_scene = preload("res://assets/Animations/LancerRunning.tscn")

func _ready():
    tower_name = "Barracks"
    damage = 0
    fire_rate = 0.0
    attack_range = 100.0
    cost = 150
    super._ready()
    spawn_timer.wait_time = spawn_rate
    spawn_timer.start()

func _on_spawn_timer():
    spawned_units = spawned_units.filter(func(u): return is_instance_valid(u))

    if spawned_units.size() < max_units:
        var unit
        if randf() < warrior_spawn_chance:
            unit = warrior_scene.instantiate()
            print("Barracks spawned a Warrior")
        else:
            unit = lancer_scene.instantiate()
            print("Barracks spawned a Lancer")
        
        unit.global_position = global_position
        get_parent().add_child(unit)
        spawned_units.append(unit)