class_name BaseFriendly
extends PathFollow2D

@export var speed: float = 60.0
@export var health: int = 100
@export var damage: int = 10

var is_dead: bool = false
var target: Node = null
var initialized: bool = false

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.flip_h = true
	anim.play("Run")

func _process(delta):
	if is_dead:
		return

	if not initialized:
		progress_ratio = 1.0
		initialized = true
		return

	# Move backward along the path — same as enemies but reversed
	progress -= speed * delta

	if progress_ratio <= 0.0:
		queue_free()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	is_dead = true
	queue_free()
