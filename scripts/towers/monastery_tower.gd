class_name MonasteryTower
extends BaseTower

@export var spawn_rate: float = 8.0
@export var max_units: int = 2
@export var heal_amount: int = 10

var monk_scene = preload("res://scenes/Units/Friendlies/FriendlyMonk.tscn")

func _ready():
	tower_name = "Monastery"
	damage = 0
	fire_rate = 0.0
	attack_range = 120.0
	cost = 150
	super._ready()
	spawn_timer.wait_time = spawn_rate
	spawn_timer.start()

func _on_spawn_timer():
	if path_node == null:
		return
	spawned_units = spawned_units.filter(func(u): return is_instance_valid(u))
	if spawned_units.size() < max_units:
		var monk = monk_scene.instantiate()
		path_node.add_child(monk)
		spawned_units.append(monk)
		print("Monastery spawned a Monk")