extends "res://scripts/enemies/enemypath.gd"
class_name PawnEnemy


func _ready():
	speed = 94.0
	max_health = 95
	attack_damage = 5
	gold_reward = 18
	gold_drop_animation_name = &"Pawn Gold"
	running_animation_name = &"Running w Axe"
	attack_animation_name = &"Attacking Axe "
	idle_animation_name = &"Running w Axe"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()
