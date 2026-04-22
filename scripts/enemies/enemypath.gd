extends PathFollow2D
class_name EnemyPath

@export var speed: float = 80.0
@export var attack_damage: int = 10
@export var detect_range: float = 60.0
@export var max_health: int = 100
@export var gold_reward: int = 10
@export var attack_scene: PackedScene
@export var idle_scene: PackedScene
@export var death_effect_scene: PackedScene = preload("res://assets/Animations/Death.tscn")
@export var gold_drop_scene: PackedScene = preload("res://assets/Animations/Gold.tscn")
@export var death_animation_name: StringName = &"Explotion"
@export var gold_drop_animation_name: StringName = &"Pawn Gold"
@export var running_animation_name: StringName = &"Running"
@export var attack_animation_name: StringName = &"Attacking"
@export var idle_animation_name: StringName = &"Idle"
@export var use_embedded_attack_animation: bool = false
@export var use_embedded_idle_animation: bool = false

var current_health: int = 0
var has_reached_end: bool = false
var is_attacking: bool = false
var attack_instance: Node = null
var attack_sprite: AnimatedSprite2D = null
var attack_count: int = 0
const MAX_ATTACKS: int = 15
var previous_attack_frame: int = -1
var attack_finished: bool = false
var is_dying: bool = false
var original_speed: float = 0.0
var target_tower = null

# Lane offset so enemies can spread out when they reach the end of the path.
var lane_index: int = 0
const LANE_SPACING: float = 32.0
var end_offset: Vector2 = Vector2.ZERO

signal enemy_finished
signal enemy_defeated(gold_reward: int)

@onready var main_sprite: AnimatedSprite2D = get_node_or_null("CharacterBody2D/AnimatedSprite2D")


func _ready():
	original_speed = speed
	current_health = max_health
	add_to_group("enemies")
	_play_main_sprite_animation(running_animation_name)


func _process(delta):
	if has_reached_end:
		if has_node("CharacterBody2D"):
			$CharacterBody2D.position = end_offset
		if attack_instance and attack_instance != $CharacterBody2D:
			attack_instance.position = end_offset
		if is_instance_valid(target_tower) and target_tower.current_health <= 0 and not attack_finished:
			attack_finished = true
			_switch_to_idle()
			emit_signal("enemy_finished")
		if attack_finished and attack_instance and attack_instance != $CharacterBody2D:
			attack_instance.position = end_offset
		if not attack_finished:
			_update_attack_visuals()
			_process_attack_loop(true)
		return

	if is_attacking:
		if not is_instance_valid(target_tower):
			_resume_movement()
			return
		_update_attack_visuals()
		_process_attack_loop(false)
		return

	progress += speed * delta

	var nearby_tower = _find_tower_in_range()
	if nearby_tower:
		is_attacking = true
		target_tower = nearby_tower
		speed = 0
		start_attack()
		return

	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		speed = 0
		has_reached_end = true

		var col = lane_index % 3
		var row = lane_index / 3
		end_offset = Vector2(-(col + 1) * LANE_SPACING, (row - 1) * LANE_SPACING)

		target_tower = _find_nearest_tower()
		start_attack()


func _resume_movement():
	is_attacking = false
	attack_count = 0
	previous_attack_frame = -1

	if attack_instance and attack_instance != $CharacterBody2D:
		attack_instance.queue_free()

	attack_instance = null
	attack_sprite = null
	speed = original_speed

	if main_sprite:
		main_sprite.visible = true
		_play_main_sprite_animation(running_animation_name)


func start_attack():
	if use_embedded_attack_animation and main_sprite:
		attack_instance = $CharacterBody2D
		attack_sprite = main_sprite
		main_sprite.visible = true
		_play_main_sprite_animation(attack_animation_name)
		_update_attack_visuals()
		previous_attack_frame = attack_sprite.frame
		return

	if main_sprite:
		main_sprite.visible = false

	if attack_scene == null:
		return

	attack_instance = attack_scene.instantiate()
	attack_instance.position = Vector2.ZERO
	add_child(attack_instance)

	attack_sprite = attack_instance.get_node_or_null("AnimatedSprite2D")
	if attack_sprite:
		_play_sprite_animation(attack_sprite, attack_animation_name)
		_update_attack_visuals()
		previous_attack_frame = attack_sprite.frame


func _switch_to_idle():
	if use_embedded_idle_animation and main_sprite:
		attack_instance = $CharacterBody2D
		attack_sprite = main_sprite
		main_sprite.visible = true
		_play_main_sprite_animation(idle_animation_name, running_animation_name)
		return

	if attack_instance and attack_instance != $CharacterBody2D:
		attack_instance.queue_free()
		attack_instance = null

	if idle_scene == null:
		if main_sprite:
			main_sprite.visible = true
			_play_main_sprite_animation(running_animation_name)
		return

	var idle_instance = idle_scene.instantiate()
	idle_instance.position = end_offset
	add_child(idle_instance)
	attack_instance = idle_instance

	attack_sprite = idle_instance.get_node_or_null("AnimatedSprite2D")
	if attack_sprite:
		_play_sprite_animation(attack_sprite, idle_animation_name, running_animation_name)


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

		if not is_instance_valid(target_tower) and end_sequence:
			target_tower = _find_nearest_tower()

		if is_instance_valid(target_tower):
			target_tower.take_damage(attack_damage)

		if end_sequence:
			var should_stop = false
			if not is_instance_valid(target_tower):
				should_stop = true
			elif target_tower.current_health <= 0:
				should_stop = true
			elif attack_count >= MAX_ATTACKS:
				should_stop = true

			if should_stop:
				var frame_count = attack_sprite.sprite_frames.get_frame_count(String(attack_sprite.animation))
				attack_sprite.stop()
				attack_sprite.frame = max(frame_count - 1, 0)
				attack_finished = true
				attack_sprite = null
				emit_signal("enemy_finished")
				return

		if not end_sequence and not is_instance_valid(target_tower):
			_resume_movement()
			return

	previous_attack_frame = current_frame


func take_damage(amount: int):
	if is_dying:
		return

	current_health -= amount
	current_health = max(current_health, 0)
	queue_redraw()
	if current_health <= 0:
		_die()


func _draw():
	var bar_w = 20.0
	var bar_h = 3.0
	var bar_x = -bar_w / 2.0
	var bar_y = 20.0

	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15, 0.85))

	var fill_w = bar_w * (float(current_health) / float(max_health))
	draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), Color(1, 0, 0, 1))


func _play_main_sprite_animation(animation_name: StringName, fallback_animation: StringName = &""):
	if main_sprite:
		_play_sprite_animation(main_sprite, animation_name, fallback_animation)


func _play_sprite_animation(sprite: AnimatedSprite2D, animation_name: StringName, fallback_animation: StringName = &""):
	if sprite == null or sprite.sprite_frames == null:
		return

	var animation_to_play := animation_name
	if not sprite.sprite_frames.has_animation(animation_to_play):
		if fallback_animation != &"" and sprite.sprite_frames.has_animation(fallback_animation):
			animation_to_play = fallback_animation
		else:
			return

	sprite.animation = animation_to_play
	sprite.play()


func _update_attack_visuals():
	pass


func _die():
	if is_dying:
		return

	is_dying = true
	emit_signal("enemy_defeated", gold_reward)
	_spawn_death_effect()
	_spawn_gold_drop()
	queue_free()


func _spawn_death_effect():
	if death_effect_scene == null:
		return

	var death_effect := death_effect_scene.instantiate()
	var effect_parent := get_parent()
	if effect_parent == null:
		return

	effect_parent.add_child(death_effect)

	if death_effect is Node2D:
		death_effect.global_position = global_position

	var death_sprite: AnimatedSprite2D = death_effect.get_node_or_null("AnimatedSprite2D")
	if death_sprite:
		_play_sprite_animation(death_sprite, death_animation_name)
		death_sprite.animation_finished.connect(func(): death_effect.queue_free(), CONNECT_ONE_SHOT)


func _spawn_gold_drop():
	if gold_drop_scene == null:
		return

	var gold_drop := gold_drop_scene.instantiate()
	var effect_parent := get_parent()
	if effect_parent == null:
		return

	effect_parent.add_child(gold_drop)

	if gold_drop is Node2D:
		gold_drop.global_position = global_position

	var gold_sprite: AnimatedSprite2D = gold_drop.get_node_or_null("AnimatedSprite2D")
	if gold_sprite == null:
		return

	_play_sprite_animation(gold_sprite, gold_drop_animation_name)

	if gold_sprite.sprite_frames and gold_sprite.sprite_frames.has_animation(StringName(gold_sprite.animation)):
		gold_sprite.animation_looped.connect(func():
			gold_drop.queue_free()
		, CONNECT_ONE_SHOT)
