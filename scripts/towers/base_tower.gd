class_name BaseTower
extends Node2D

@export var tower_name: String = "Base Tower"
@export var damage: int = 0
@export var fire_rate: float = 1.0
@export var attack_range: float = 150.0
@export var cost: int = 100

var is_placed: bool = false
var spawned_units: Array = []   # tracks all living units this tower spawned
var spawn_timer: Timer          # controls spawn timing

func _ready():
    print("Tower placed: ", tower_name, " at ", global_position)
    _setup_timer()

func _setup_timer():
    spawn_timer = Timer.new()
    spawn_timer.wait_time = 1.0   # subclasses override this with their spawn_rate
    spawn_timer.autostart = false
    spawn_timer.timeout.connect(_on_spawn_timer)
    add_child(spawn_timer)

# Subclasses override this to define what gets spawned
func _on_spawn_timer():
    pass

func _draw():
    if is_placed:
        draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 0, 0.15))