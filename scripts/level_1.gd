extends Node2D

# Prereloading the enemy 
@export var enemy_scene = preload("res://assets/Animations/LancerRunning.tscn")
@export var enemy_attack = preload("res://assets/Animations/LancerAttacking.tscn")
# Preload Towers for placement
@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")

# Tracks all placed towers in order
var placed_towers = []

func _ready():
	spawn_enemy()

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
