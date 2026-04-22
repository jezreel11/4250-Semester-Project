class_name WarriorEnemy
extends EnemyPath

func _ready():
	max_health = 160
	attack_damage = 20
	death_animation_name = &"Bigger Explotion"
	running_animation_name = &"Running"
	attack_animation_name = &"Attacking"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()