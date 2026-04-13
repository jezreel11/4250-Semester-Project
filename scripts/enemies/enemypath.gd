extends PathFollow2D 

@export var speed : float = 80.0
@onready var attack_scene = preload("res://assets/Animations/LancerAttacking.tscn")
var has_attacked : bool = false
var attack_instance : Node = null
var attack_sprite : AnimatedSprite2D = null
var attack_count : int = 0
const MAX_ATTACKS : int = 15
var previous_attack_frame : int = -1
var attack_finished : bool = false

func _process(delta):
    if has_attacked:
        if not attack_finished:
            _process_attack_loop()
        return

    progress += speed * delta
    if progress_ratio >= 1.0:
        progress_ratio = 1.0
        speed = 0
        has_attacked = true
        start_attack()

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

func _process_attack_loop():
    if not attack_sprite:
        return

    var current_frame = attack_sprite.frame
    if previous_attack_frame > current_frame:
        attack_count += 1
        if attack_count >= MAX_ATTACKS:
            var frame_count = attack_sprite.sprite_frames.get_frame_count("Attacking")
            attack_sprite.stop()
            attack_sprite.frame = max(frame_count - 1, 0)
            attack_finished = true
            attack_sprite = null
            return
    previous_attack_frame = current_frame
		
