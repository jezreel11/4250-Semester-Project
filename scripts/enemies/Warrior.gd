extends "res://scripts/enemies/enemypath.gd"
class_name WarriorEnemy


func _ready():
	speed = 68.0
	max_health = 225
	attack_damage = 18
	gold_reward = 44
	gold_drop_animation_name = &"Warrior Gold"
	death_animation_name = &"Bigger Explotion"
	running_animation_name = &"Running"
	attack_animation_name = &"Attacking"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
