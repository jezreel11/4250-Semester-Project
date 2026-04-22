class_name FriendlyWarrior
extends BaseFriendly

func _ready():
	speed = 50.0  # slower but tankier
	health = 150
	damage = 25
	super._ready()