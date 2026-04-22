extends PathFollow2D

@export var speed: float = 80.0
@onready var attack_scene = preload("res://scenes/Units/Enemies/LancerAttacking.tscn")

# Tracks whether this enemy has already started attacking
var has_attacked: bool = false
var attack_instance: Node = null
var attack_sprite: AnimatedSprite2D = null
var attack_count: int = 0
const MAX_ATTACKS: int = 15
var previous_attack_frame: int = -1
var attack_finished: bool = false

# Lane offset — each enemy gets a unique index so they spread out
# alternating up and down at the end of the path instead of stacking
var lane_index: int = 0
const LANE_SPACING: float = 32.0


func _process(delta):
	# If the enemy has reached the end, process the attack loop instead
	if has_attacked:
		if not attack_finished:
			_process_attack_loop()
		return

	# Move the enemy along the path
	progress += speed * delta

	# Check if the enemy has reached the end of the path
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		speed = 0
		has_attacked = true

		# Alternate enemies above and below the end point
		# even lane_index goes down, odd goes up
		# 0 = down 32, 1 = up 32, 2 = down 64, 3 = up 64, etc.
		var offset = (lane_index / 2 + 1) * LANE_SPACING
		if lane_index % 2 == 0:
			position.y += offset
		else:
			position.y -= offset

		start_attack()


func start_attack():
	# Hide the running animation when switching to attack
	if has_node("CharacterBody2D/AnimatedSprite2D"):
		$CharacterBody2D/AnimatedSprite2D.visible = false

	# Instantiate the attack scene and attach it to this enemy
	attack_instance = attack_scene.instantiate()
	attack_instance.position = Vector2.ZERO
	add_child(attack_instance)

	# Grab the AnimatedSprite2D and start playing the attack animation
	attack_sprite = attack_instance.get_node_or_null("AnimatedSprite2D")
	if attack_sprite:
		attack_sprite.animation = "Attacking"
		attack_sprite.play()
		previous_attack_frame = attack_sprite.frame


func _process_attack_loop():
	if not attack_sprite:
		return

	# Detect when the animation loops back to frame 0 (one full cycle done)
	var current_frame = attack_sprite.frame
	if previous_attack_frame > current_frame:
		attack_count += 1

		# Stop after MAX_ATTACKS cycles and freeze on the last frame
		if attack_count >= MAX_ATTACKS:
			var frame_count = attack_sprite.sprite_frames.get_frame_count("Attacking")
			attack_sprite.stop()
			attack_sprite.frame = max(frame_count - 1, 0)
			attack_finished = true
			attack_sprite = null
			return

	previous_attack_frame = current_frame