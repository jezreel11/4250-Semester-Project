class_name ArcherTower
extends BaseTower

@export var spawn_rate: float = 5.0
@export var max_units: int = 3

var archer_scene = preload("res://assets/Animations/LancerRunning.tscn")  # swap with your Archer scene when ready

func _ready():
    tower_name = "Archer Tower"
    damage = 15
    fire_rate = 2.0
    attack_range = 200.0
    cost = 100
    super._ready()
    spawn_timer.wait_time = spawn_rate
    spawn_timer.start()

func _on_spawn_timer():
    # Clean up any units that have been freed
    spawned_units = spawned_units.filter(func(u): return is_instance_valid(u))
    
    if spawned_units.size() < max_units:
        var unit = archer_scene.instantiate()
        unit.global_position = global_position
        get_parent().add_child(unit)
        spawned_units.append(unit)
        print("Archer Tower spawned an Archer")