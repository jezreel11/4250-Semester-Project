class_name FriendlyArcher
extends BaseFriendly

func _ready():
	speed = 60.0
	health = 80
	damage = 15
	attack_range = 165.0
	attack_cooldown = 0.9
	attack_animation_name = &"Shoot"
	uses_projectile = true
	super._ready()
