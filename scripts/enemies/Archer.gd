extends "res://scripts/enemies/enemypath.gd"
class_name ArcherEnemy


func _ready():
	max_health = 180
	attack_damage = 15
	detect_range = 100.0
	death_animation_name = &"Bigger Explotion"
	running_animation_name = &"Running"
	attack_animation_name = &"Shooting"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
