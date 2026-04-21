extends "res://scripts/enemies/enemypath.gd"
class_name LancerEnemy


func _ready():
	max_health = 140
	attack_damage = 20
	attack_scene = preload("res://assets/Animations/LancerAttacking.tscn")
	idle_scene = preload("res://assets/Animations/LancerIdle.tscn")
	running_animation_name = &"Running"
	attack_animation_name = &"Attacking"
	idle_animation_name = &"Idle"
	use_embedded_attack_animation = false
	use_embedded_idle_animation = false
	super()
