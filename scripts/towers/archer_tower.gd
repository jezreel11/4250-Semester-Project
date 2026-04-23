class_name ArcherTower
extends BaseTower

@export var spawn_rate: float = 5.0
@export var max_units: int = 3

var archer_scene = preload("res://scenes/Units/Friendlies/FriendlyArcher.tscn")

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
	if path_node == null:
		return
	spawned_units = spawned_units.filter(func(u): return is_instance_valid(u))
	if spawned_units.size() < max_units:
		var unit = archer_scene.instantiate()
		path_node.add_child(unit)
		spawned_units.append(unit)
		print("Archer Tower spawned an Archer")

func _draw():
	super._draw()