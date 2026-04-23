class_name FriendlyMonk
extends BaseFriendly

@export var heal_amount: int = 10
@export var heal_range: float = 80.0

func _ready():
	speed = 55.0
	health = 70   # fragile but supportive
	damage = 0
	super._ready()