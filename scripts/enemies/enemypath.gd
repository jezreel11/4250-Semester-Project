extends PathFollow2D

@export var speed: float = 80.0
@export var attack_damage: int = 10
@export var detect_range: float = 60.0
@onready var attack_scene = preload("res://assets/Animations/LancerAttacking.tscn")

var max_health: int = 100
var current_health: int = 100

var has_reached_end: bool = false
var is_attacking: bool = false
var attack_instance: Node = null
var attack_sprite: AnimatedSprite2D = null
var attack_count: int = 0
const MAX_ATTACKS: int = 15
var previous_attack_frame: int = -1
var attack_finished: bool = false
var original_speed: float = 0.0

var target_tower = null

# Lane offset — each enemy gets a unique index so they spread out
var lane_index: int = 0
const LANE_SPACING: float = 32.0
var end_offset: Vector2 = Vector2.ZERO


func _ready():
	original_speed = speed
	add_to_group("enemies")


func _process(delta):
	# End-of-path attack sequence
	if has_reached_end:
		# Force children to offset position every frame
		if has_node("CharacterBody2D"):
			$CharacterBody2D.position = end_offset
		if attack_instance:
			attack_instance.position = end_offset
		if not attack_finished:
			_process_attack_loop(true)
		return

	# Mid-path attacking a tower
	if is_attacking:
		if not is_instance_valid(target_tower):
			_resume_movement()
			return
		_process_attack_loop(false)
		return

	# Move along path
	progress += speed * delta

	# Check for a tower nearby while walking
	var nearby_tower = _find_tower_in_range()
	if nearby_tower:
		is_attacking = true
		target_tower = nearby_tower
		speed = 0
		start_attack()
		return

	# Check if reached end of path
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		speed = 0
		has_reached_end = true

		# Spread enemies so they don't stack — line up in rows
		var col = lane_index % 3
		var row = lane_index / 3
		end_offset = Vector2(-(col + 1) * LANE_SPACING, (row - 1) * LANE_SPACING)

		target_tower = _find_nearest_tower()
		start_attack()


func _resume_movement():
	is_attacking = false
	attack_count = 0
	previous_attack_frame = -1
	if attack_instance:
		attack_instance.queue_free()
		attack_instance = null
	attack_sprite = null
	speed = original_speed
	if has_node("CharacterBody2D/AnimatedSprite2D"):
		$CharacterBody2D/AnimatedSprite2D.visible = true


func start_attack():
	if has_node("CharacterBody2D/AnimatedSprite2D"):
		$CharacterBody2D/AnimatedSprite2D.visible = false

	attack_instance = attack_scene.instantiate()
	attack_instance.position = Vector2.ZERO
	add_child(attack_instance)

	attack_sprite = attack_instance.get_node_or_null("AnimatedSprite2D")
	if attack_sprite:
		attack_sprite.animation = "Attacking"
		attack_sprite.play()
		previous_attack_frame = attack_sprite.frame


func _find_tower_in_range() -> Node:
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if is_instance_valid(tower):
			var dist = global_position.distance_to(tower.global_position)
			if dist <= detect_range:
				return tower
	return null


func _find_nearest_tower() -> Node:
	var towers = get_tree().get_nodes_in_group("towers")
	var nearest = null
	var nearest_dist = INF
	for tower in towers:
		if is_instance_valid(tower):
			var dist = global_position.distance_to(tower.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = tower
	return nearest


func _process_attack_loop(end_sequence: bool):
	if not attack_sprite:
		return

	var current_frame = attack_sprite.frame
	if previous_attack_frame > current_frame:
		attack_count += 1

		# Deal damage each animation cycle
		if not is_instance_valid(target_tower):
			if end_sequence:
				target_tower = _find_nearest_tower()
		if is_instance_valid(target_tower):
			target_tower.take_damage(attack_damage)

		# End-of-path: stop after MAX_ATTACKS and freeze
		if end_sequence and attack_count >= MAX_ATTACKS:
			var frame_count = attack_sprite.sprite_frames.get_frame_count("Attacking")
			attack_sprite.stop()
			attack_sprite.frame = max(frame_count - 1, 0)
			attack_finished = true
			attack_sprite = null
			return

		# Mid-path: resume walking once the tower is dead
		if not end_sequence and not is_instance_valid(target_tower):
			_resume_movement()
			return

	previous_attack_frame = current_frame


func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)
	queue_redraw()
	if current_health <= 0:
		queue_free()


func _draw():
	var bar_w = 20.0
	var bar_h = 3.0
	var bar_x = -bar_w / 2.0
	var bar_y = 20.0

	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15, 0.85))

	var fill_w = bar_w * (float(current_health) / float(max_health))
	draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), Color(1, 0, 0, 1))
