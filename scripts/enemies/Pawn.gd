extends "res://scripts/enemies/enemypath.gd"
class_name PawnEnemy


func _ready():
	max_health = 100
	attack_damage = 5
	running_animation_name = &"Running w Axe"
	attack_animation_name = &"Attacking Axe "
	idle_animation_name = &"Running w Axe"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
