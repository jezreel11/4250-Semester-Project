class_name BaseTower

extends Node2D

@export var tower_name: String = "Base Tower"

@export var damage: int = 0

@export var fire_rate: float = 1.0

@export var attack_range: float = 150.0

@export var cost: int = 100

@export var max_health: int = 100

var current_health: int = 100

var is_placed: bool = false

var spawned_units: Array = []	# tracks all living units this tower spawned

var spawn_timer: Timer			# controls spawn timing

func _ready():

	add_to_group("towers")

	current_health = max_health

	print("Tower placed: ", tower_name, " at ", global_position)

	_setup_timer()

	queue_redraw()

func _setup_timer():

	spawn_timer = Timer.new()

	spawn_timer.wait_time = 1.0		# subclasses override this with their spawn_rate

	spawn_timer.autostart = false

	spawn_timer.timeout.connect(_on_spawn_timer)

	add_child(spawn_timer)

# Subclasses override this to define what gets spawned

func _on_spawn_timer():

	pass

func take_damage(amount: int):

	current_health -= amount

	current_health = max(current_health, 0)

	queue_redraw()

	if current_health <= 0:

		queue_free()

func _draw():

	if is_placed:

		draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 0, 0.15))

	# Draw health bar — compensate for node scale so it appears the same size on all towers
	var s = scale

	var bar_w = 40.0 / s.x

	var bar_h = 5.0 / s.y

	var bar_x = -bar_w / 2.0

	var bar_y = 35.0 / s.y

	# Dark background
	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15, 0.85))

	# Blue fill based on current health
	var fill_w = bar_w * (float(current_health) / float(max_health))

	draw_rect(Rect2(bar_x, bar_y, fill_w, bar_h), Color(0, 0.5, 1, 1))
