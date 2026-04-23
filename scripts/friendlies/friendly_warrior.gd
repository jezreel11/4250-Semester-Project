class_name FriendlyWarrior
extends BaseFriendly

func _ready():
	speed = 50.0  # slower but tankier
	health = 150
	damage = 25
	attack_range = 38.0
	attack_cooldown = 1.05
	attack_animation_name = &"Attack1"
	super._ready()
