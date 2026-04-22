extends "res://scripts/enemies/enemypath.gd"
class_name ArcherEnemy


func _ready():
	speed = 74.0
	max_health = 155
	attack_damage = 13
	gold_reward = 36
	gold_drop_animation_name = &"Archer Gold"
	detect_range = 110.0
	death_animation_name = &"Bigger Explotion"
	running_animation_name = &"Running"
	attack_animation_name = &"Shooting"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
