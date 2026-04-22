extends Node2D

# Preloading the enemy scenes
@export var enemy_scene = preload("res://assets/Animations/Lancer.tscn")

# Preload Towers for placement
@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")
@onready var placement_zones = $GameManager/Map/PlacementZones
@onready var game_message_label: Label = $UI/InsufficientFundsLabel

# Dictionary of all available tower types
var tower_scenes = {
	"cannon":    preload("res://scenes/towers/Tower.tscn"),
	"archer":    preload("res://scenes/towers/ArcherTower.tscn"),
	"barracks":  preload("res://scenes/towers/BarracksTower.tscn"),
	"monastery": preload("res://scenes/towers/MonasteryTower.tscn")
}

# Tracks all placed towers in order
var placed_towers = []

# Currently selected tower type
var selected_tower = "cannon"

# --- WAVE SETTINGS ---
# How many enemies spawn per wave (editable in inspector)
@export var wave_size: int = 5

# How many seconds between each enemy spawn (editable in inspector)
@export var spawn_interval: float = 2.0

# Tracks how many enemies have been spawned so far
var enemies_spawned: int = 0

# The timer node that triggers each enemy spawn
var spawn_timer: Timer

var player_currency: int = 100  # starting money
var game_message_tween: Tween
var game_message_id: int = 0

func _ready():
	# Set up the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

	game_message_label.modulate.a = 0.0
	game_message_label.visible = false


func _on_spawn_timer_timeout():
	# Spawn an enemy if we haven't hit the wave size yet
	if enemies_spawned < wave_size:
		spawn_enemy()
		enemies_spawned += 1
	else:
		# All enemies spawned — stop the timer
		spawn_timer.stop()


func spawn_enemy():
	# Instantiate a new enemy and add it to the path
	var enemy = enemy_scene.instantiate()

	# Add to scene tree first so the script is fully initialized
	$GameManager/Map/Path2D.add_child(enemy)

	# Then set the lane index so the enemy knows its offset at the end
	enemy.lane_index = enemies_spawned


var tower_costs = {
	"cannon": 100,
	"archer": 175,
	"barracks": 225,
	"monastery": 300
}


func _can_place_tower(world_pos: Vector2) -> bool:
	# Check if the position is within any valid placement zone
	for zone in placement_zones.get_children():
		if zone is Area2D:
			var shape = zone.get_node("CollisionShape2D")
			var rect_shape = shape.shape as RectangleShape2D
			if rect_shape:
				var local_pos = zone.global_transform.affine_inverse() * world_pos
				var half_size = rect_shape.size / 2
				if abs(local_pos.x) <= half_size.x and abs(local_pos.y) <= half_size.y:
					return true
	return false


func _is_occupied(world_pos: Vector2) -> bool:
	# Check if a tower is already too close to this position
	for tower in placed_towers:
		if is_instance_valid(tower):
			if tower.global_position.distance_to(world_pos) < 70.0:
				return true
	return false


func _input(event):
	# --- TOWER SELECTION ---
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			selected_tower = "cannon"
			print("Selected: Cannon Tower")
			_show_game_message("Selected: Cannon Tower")
		elif event.keycode == KEY_2:
			selected_tower = "archer"
			print("Selected: Archer Tower")
			_show_game_message("Selected: Archer Tower")
		elif event.keycode == KEY_3:
			selected_tower = "barracks"
			print("Selected: Barracks")
			_show_game_message("Selected: Barracks")
		elif event.keycode == KEY_4:
			selected_tower = "monastery"
			print("Selected: Monastery")
			_show_game_message("Selected: Monastery")
		elif event.keycode == KEY_BACKSPACE:
			# Remove the last placed tower
			if placed_towers.size() > 0:
				var last_tower = placed_towers.pop_back()
				last_tower.queue_free()
				print("Tower removed")
				_show_game_message("Tower removed")

	# --- TOWER PLACEMENT ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = get_global_mouse_position()

			# First check: is the spot valid?
			if not _can_place_tower(click_pos):
				print("Can't place tower here!")
				_show_game_message("Can't place tower here!", event.position)
				return

			# Second check: is the spot occupied?
			if _is_occupied(click_pos):
				print("Too close to another tower!")
				_show_game_message("Too close to another tower!", event.position)
				return

			# Third check: does the player have enough money?
			var cost = tower_costs[selected_tower]
			if player_currency < cost:
				var insufficient_message := "Not enough currency! Need %d, but have %d." % [cost, player_currency]
				print(insufficient_message)
				_show_game_message(insufficient_message, event.position)
				return

			# If all checks pass → place tower
			player_currency -= cost

			var tower = tower_scenes[selected_tower].instantiate()
			tower.global_position = click_pos
			add_child(tower)
			placed_towers.append(tower)

			var placed_message := "Placed: %s (Cost: %d)" % [selected_tower, cost]
			var currency_message := "Currency left: %d" % player_currency
			print(placed_message, " ", currency_message)
			print(currency_message)
			_show_game_message("%s. %s" % [placed_message, currency_message])


func _show_game_message(message: String, cursor_pos: Vector2 = Vector2(-1, -1)):
	game_message_id += 1
	var message_id := game_message_id

	game_message_label.text = message
	game_message_label.visible = true
	game_message_label.scale = Vector2(0.96, 0.96)
	game_message_label.modulate = Color(0.98, 0.94, 0.78, 0.0)

	var label_size := game_message_label.size
	var viewport_size := get_viewport_rect().size
	var use_cursor := cursor_pos.x >= 0.0 and cursor_pos.y >= 0.0
	var start_pos := Vector2.ZERO

	if use_cursor:
		start_pos = Vector2(
			clamp(cursor_pos.x - (label_size.x / 2.0), 12.0, viewport_size.x - label_size.x - 12.0),
			clamp(cursor_pos.y - 42.0, 12.0, viewport_size.y - label_size.y - 12.0)
		)
	else:
		start_pos = Vector2(
			(viewport_size.x - label_size.x) / 2.0,
			24.0
		)

	var end_pos := start_pos + Vector2(0.0, -10.0)

	game_message_label.position = start_pos

	if game_message_tween:
		game_message_tween.kill()

	game_message_tween = create_tween()
	game_message_tween.set_parallel(true)
	game_message_tween.tween_property(game_message_label, "modulate:a", 1.0, 0.14)
	game_message_tween.tween_property(game_message_label, "scale", Vector2.ONE, 0.18)
	game_message_tween.tween_property(game_message_label, "position", end_pos, 0.22)
	game_message_tween.finished.connect(func():
		if message_id != game_message_id:
			return

		game_message_tween = create_tween()
		game_message_tween.tween_interval(1.57)
		game_message_tween.finished.connect(func():
			if message_id != game_message_id:
				return

			game_message_tween = create_tween()
			game_message_tween.set_parallel(true)
			game_message_tween.tween_property(game_message_label, "modulate:a", 0.0, 0.35)
			game_message_tween.tween_property(game_message_label, "position", end_pos + Vector2(0.0, -6.0), 0.35)
			game_message_tween.finished.connect(func():
				if message_id == game_message_id:
					game_message_label.visible = false
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)
