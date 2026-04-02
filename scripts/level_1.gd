extends Node2D

# Prereloading the enemy 
@export var enemy_scene = preload("res://assets/Animations/LancerRunning.tscn")

@export var enemy_attack = preload("res://assets/Animations/LancerAttacking.tscn")

# Spawning an enemy and connecting the animation to this level
func _ready():
	spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	$GameManager/Map/Path2D.add_child(enemy)
