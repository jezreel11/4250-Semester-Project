extends Node2D

# Preloading the enemy 
@export var enemy_scene = preload("res://assets/Animations/LancerRunning.tscn")
@export var enemy_attack = preload("res://assets/Animations/LancerAttacking.tscn")

# Preload Towers for placement
@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")

# Tracks all placed towers in order
var placed_towers = []

# -- here is the wave management variables --

# this here is the wave size controls how many enemies spawn in one wave (can be edited in Godot but im not too experienced with that yet so i just set it here for now) - deshaun
@export var wave_size : int = 3
@export var spawn_interval : float = 1.0 # Time in seconds between enemy spawns

var enemies_spawned : int = 0
var spawn_timer : Timer


func _ready():
	# Initialize the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemies_spawned < wave_size:
		spawn_enemy()
		enemies_spawned += 1
	else:		
		spawn_timer.stop() # Stop the timer when the wave is complete

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	$GameManager/Map/Path2D.add_child(enemy)

func _input(event):
	# Left click — place a tower
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var tower = tower_scene.instantiate()
			tower.global_position = get_global_mouse_position()
			add_child(tower)
			placed_towers.append(tower)

	# Backspace — remove the last placed tower
	if event is InputEventKey:
		if event.keycode == KEY_BACKSPACE and event.pressed:
			if placed_towers.size() > 0:
				var last_tower = placed_towers.pop_back()
				last_tower.queue_free()
