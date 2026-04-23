class_name BaseFriendly
extends PathFollow2D

const PROJECTILE_SCRIPT = preload("res://scripts/projectile.gd")
const ARROW_TEXTURE = preload("res://assets/Units/Blue Units/Archer/Arrow.png")

@export var speed: float = 60.0
@export var health: int = 100
@export var damage: int = 10
@export var attack_range: float = 36.0
@export var attack_cooldown: float = 1.0
@export var attack_animation_name: StringName = &"Attack"
@export var run_animation_name: StringName = &"Run"
@export var uses_projectile: bool = false

var is_dead: bool = false
var target: Node2D = null
var initialized: bool = false
var attack_timer: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	anim.flip_h = true
	_play_animation(run_animation_name)


func _process(delta):
	if is_dead:
		return

	attack_timer = maxf(attack_timer - delta, 0.0)

	if not initialized:
		progress_ratio = 1.0
		initialized = true
		return

	target = _find_enemy_in_range()
	if is_instance_valid(target):
		_attack_target()
		return

	_play_animation(run_animation_name)
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


func _find_enemy_in_range() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := attack_range

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue

		var distance := global_position.distance_to(enemy.global_position)
		if distance <= nearest_distance:
			nearest = enemy
			nearest_distance = distance

	return nearest


func _attack_target() -> void:
	_play_animation(attack_animation_name)

	if attack_timer > 0.0 or damage <= 0:
		return

	attack_timer = attack_cooldown

	if uses_projectile:
		_shoot_target()
	elif target.has_method("take_damage"):
		target.take_damage(damage)


func _shoot_target() -> void:
	var projectile := Node2D.new()
	projectile.set_script(PROJECTILE_SCRIPT)
	projectile.global_position = global_position + Vector2(0.0, -10.0)
	projectile.set("damage", damage)
	projectile.set("target", target)
	projectile.set("texture", ARROW_TEXTURE)
	projectile.set("texture_scale", Vector2(0.45, 0.45))
	get_parent().add_child(projectile)


func _play_animation(animation_name: StringName) -> void:
	if anim == null or anim.sprite_frames == null:
		return

	if not anim.sprite_frames.has_animation(animation_name):
		return

	if anim.animation != animation_name:
		anim.animation = animation_name
	anim.play()
