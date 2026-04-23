class_name FriendlyLancer
extends BaseFriendly

func _ready():
	speed = 70.0  # fastest unit
	health = 100
	damage = 20
	attack_range = 34.0
	attack_cooldown = 0.85
	attack_animation_name = &"Attack"
	super._ready()
