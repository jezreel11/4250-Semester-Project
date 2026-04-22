extends "res://scripts/enemies/enemypath.gd"
class_name LancerEnemy


func _ready():
	speed = 86.0
	max_health = 145
	attack_damage = 11
	gold_reward = 28
	gold_drop_animation_name = &"Lancer Gold"
	running_animation_name = &"Running"
	attack_animation_name = &"Attacking Right"
	idle_animation_name = &"Running"
	use_embedded_attack_animation = true
	use_embedded_idle_animation = true
	super()


func _update_attack_visuals():
	if attack_sprite == null or target_tower == null or not is_instance_valid(target_tower):
		return

	var offset: Vector2 = target_tower.global_position - global_position
	var abs_x := absf(offset.x)
	var abs_y := absf(offset.y)
	var next_animation: StringName = &"Attacking Right"

	if abs_y > abs_x * 1.5:
		if offset.y < 0.0:
			next_animation = &"Attacking Up"
		else:
			next_animation = &"Attacking Down"
	else:
		if offset.y < -12.0:
			next_animation = &"Attacking Up Right"
		elif offset.y > 12.0:
			next_animation = &"Attacking Down Right"
		else:
			next_animation = &"Attacking Right"

	var should_flip := offset.x < 0.0
	if attack_sprite.animation != next_animation or attack_sprite.flip_h != should_flip:
		attack_sprite.flip_h = should_flip
		attack_sprite.animation = next_animation
		attack_sprite.play()
		previous_attack_frame = attack_sprite.frame
