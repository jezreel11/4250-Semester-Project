extends "res://scripts/enemies/enemypath.gd"
class_name WarriorEnemy


func _ready():
	max_health = 160
	attack_damage = 20
	running_animation_name = &"Running"
	attack_animation_name = &"Attacking"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
