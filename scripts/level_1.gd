extends Node2D

# Preload Towers for placement
@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")
@onready var game_manager = $GameManager
@onready var placement_zones = $GameManager/Map/PlacementZones
@onready var base_node = $GameManager/Map/Base
@onready var backdrop: Sprite2D = $Backdrop
@onready var camera: Camera2D = $Camera2D
@onready var game_message_label: Label = $UI/InsufficientFundsLabel
@onready var currency_label: Label = $UI/HUDRoot/TopBar/StatsMargin/StatsColumn/GoldBadge/GoldPadding/CurrencyLabel
@onready var base_health_label: Label = $UI/HUDRoot/TopBar/StatsMargin/StatsColumn/HealthBadge/HealthPadding/BaseHealthLabel
@onready var selected_tower_label: Label = $UI/HUDRoot/TopBar/StatsMargin/StatsColumn/ReadyBadge/ReadyPadding/SelectedTowerLabel
@onready var cannon_button: Button = $UI/HUDRoot/BuildBar/BuildMargin/BuildColumn/TowerButtons/CannonButton
@onready var archer_button: Button = $UI/HUDRoot/BuildBar/BuildMargin/BuildColumn/TowerButtons/ArcherButton
@onready var barracks_button: Button = $UI/HUDRoot/BuildBar/BuildMargin/BuildColumn/TowerButtons/BarracksButton
@onready var monastery_button: Button = $UI/HUDRoot/BuildBar/BuildMargin/BuildColumn/TowerButtons/MonasteryButton

# Dictionary of all available tower types
var tower_scenes = {
	"cannon": preload("res://scenes/towers/Tower.tscn"),
	"archer": preload("res://scenes/towers/ArcherTower.tscn"),
	"barracks": preload("res://scenes/towers/BarracksTower.tscn"),
	"monastery": preload("res://scenes/towers/MonasteryTower.tscn")
}

var tower_costs = {
	"cannon": 100,
	"archer": 175,
	"barracks": 225,
	"monastery": 300
}

var tower_display_names = {
	"cannon": "Cannon",
	"archer": "Archer",
	"barracks": "Barracks",
	"monastery": "Monastery"
}

var tower_hotkeys = {
	"cannon": "1",
	"archer": "2",
	"barracks": "3",
	"monastery": "4"
}

# Tracks all placed towers in order
var placed_towers = []

# Currently selected tower type
var selected_tower = "cannon"

# --- WAVE SETTINGS ---
var enemy_scenes = {
	"pawn": preload("res://assets/Animations/Pawn.tscn"),
	"lancer": preload("res://assets/Animations/Lancer.tscn"),
	"archer": preload("res://assets/Animations/Archer.tscn"),
	"warrior": preload("res://assets/Animations/Warrior.tscn")
}

var spawn_timer: Timer
var wave_timer: Timer
var tower_buttons: Dictionary
var wave_definitions: Array = []
var current_wave_index: int = -1
var current_wave_queue: Array = []
var total_enemies_spawned: int = 0

var player_currency: int = 100 # starting money
var game_message_tween: Tween
var game_message_id: int = 0
const BACKDROP_ZOOM_MULTIPLIER: float = 1.12
const BATTLEFIELD_MARGIN: Vector2 = Vector2(-18.0, -18.0)
const INTERMISSION_DURATION: float = 4.0


func _ready():
	wave_definitions = _build_wave_definitions()

	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)

	game_message_label.modulate.a = 0.0
	game_message_label.visible = false

	tower_buttons = {
		"cannon": cannon_button,
		"archer": archer_button,
		"barracks": barracks_button,
		"monastery": monastery_button
	}

	_connect_tower_buttons()
	base_node.health_changed.connect(_on_base_health_changed)
	_on_base_health_changed(base_node.current_health, base_node.max_health)
	_sync_backdrop()
	get_viewport().size_changed.connect(_sync_backdrop)
	_refresh_hud()
	_start_wave(0)


func _process(_delta: float) -> void:
	_sync_backdrop()


func _on_spawn_timer_timeout():
	if current_wave_queue.is_empty():
		return

	var enemy_key: String = String(current_wave_queue.pop_front())
	_spawn_enemy(enemy_key)

	if current_wave_queue.is_empty():
		if current_wave_index >= wave_definitions.size() - 1:
			_show_game_message("Final wave deployed!")
		else:
			_show_game_message("Wave %d incoming soon." % [current_wave_index + 2])
			wave_timer.wait_time = INTERMISSION_DURATION
			wave_timer.start()
		return

	var current_wave: Dictionary = wave_definitions[current_wave_index]
	spawn_timer.wait_time = float(current_wave.get("interval", 1.25))
	spawn_timer.start()


func _on_wave_timer_timeout() -> void:
	_start_wave(current_wave_index + 1)


func _start_wave(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= wave_definitions.size():
		return

	current_wave_index = wave_index
	var current_wave: Dictionary = wave_definitions[wave_index]
	current_wave_queue = Array(current_wave.get("enemies", [])).duplicate()

	var wave_name := String(current_wave.get("name", "Wave %d" % [wave_index + 1]))
	_show_game_message("Wave %d: %s" % [wave_index + 1, wave_name])

	if current_wave_queue.is_empty():
		return

	spawn_timer.wait_time = 0.6
	spawn_timer.start()


func _spawn_enemy(enemy_key: String):
	# Instantiate a new enemy and add it to the path
	var enemy_scene = enemy_scenes.get(enemy_key)
	if enemy_scene == null:
		return

	var enemy = enemy_scene.instantiate()

	# Add to scene tree first so the script is fully initialized
	$GameManager/Map/Path2D.add_child(enemy)

	if enemy is Node and enemy.has_signal("enemy_defeated"):
		enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))

	# Then set the lane index so the enemy knows its offset at the end
	enemy.lane_index = total_enemies_spawned
	total_enemies_spawned += 1


func _build_wave_definitions() -> Array:
	return [
		{
			"name": "Scouting Party",
			"interval": 1.45,
			"enemies": ["pawn", "pawn", "pawn", "pawn", "lancer"]
		},
		{
			"name": "First Push",
			"interval": 1.25,
			"enemies": ["pawn", "pawn", "lancer", "pawn", "lancer", "archer", "pawn"]
		},
		{
			"name": "Split Pressure",
			"interval": 1.12,
			"enemies": ["pawn", "archer", "lancer", "pawn", "archer", "lancer", "pawn", "warrior"]
		},
		{
			"name": "Iron Advance",
			"interval": 1.0,
			"enemies": ["lancer", "pawn", "warrior", "archer", "lancer", "pawn", "archer", "warrior", "pawn"]
		},
		{
			"name": "Crossfire Column",
			"interval": 0.92,
			"enemies": ["archer", "pawn", "lancer", "warrior", "archer", "pawn", "warrior", "lancer", "archer", "pawn"]
		},
		{
			"name": "Final Warband",
			"interval": 0.84,
			"enemies": ["warrior", "archer", "lancer", "pawn", "warrior", "archer", "pawn", "lancer", "warrior", "archer", "pawn", "warrior"]
		}
	]


func _connect_tower_buttons() -> void:
	cannon_button.pressed.connect(func(): _select_tower("cannon"))
	archer_button.pressed.connect(func(): _select_tower("archer"))
	barracks_button.pressed.connect(func(): _select_tower("barracks"))
	monastery_button.pressed.connect(func(): _select_tower("monastery"))


func _select_tower(tower_type: String) -> void:
	if player_currency < tower_costs[tower_type]:
		var insufficient_message := "Not enough coins for %s! Need %d, but have %d." % [
			tower_display_names[tower_type],
			tower_costs[tower_type],
			player_currency
		]
		print(insufficient_message)
		_show_game_message(insufficient_message)
		return

	selected_tower = tower_type
	print("Selected: ", tower_display_names[tower_type])
	_refresh_hud()
	_show_game_message("Selected: %s" % tower_display_names[tower_type])


func _refresh_hud() -> void:
	currency_label.text = "Gold: %d" % player_currency
	selected_tower_label.text = "Ready: %s" % tower_display_names[selected_tower]
	_update_tower_buttons()


func _sync_backdrop() -> void:
	if not is_instance_valid(backdrop) or not is_instance_valid(camera):
		return

	if backdrop.texture == null:
		return

	var texture_size := backdrop.texture.get_size()
	if texture_size == Vector2.ZERO:
		return

	var viewport_size := get_viewport_rect().size
	var cover_scale: float = maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)

	backdrop.global_position = camera.global_position
	backdrop.scale = Vector2.ONE * (cover_scale * BACKDROP_ZOOM_MULTIPLIER)


func _update_tower_buttons() -> void:
	for tower_key in tower_buttons.keys():
		var tower_type: String = String(tower_key)
		var button: Button = tower_buttons[tower_type]
		var is_selected: bool = tower_type == selected_tower
		var is_affordable: bool = player_currency >= tower_costs[tower_type]
		var label := "%s\n%dg [%s]" % [
			tower_display_names[tower_type],
			tower_costs[tower_type],
			tower_hotkeys[tower_type]
		]
		button.text = label
		button.disabled = false
		if not is_affordable:
			button.self_modulate = Color(0.6, 0.58, 0.54, 0.92)
		elif is_selected:
			button.self_modulate = Color(1.0, 0.94, 0.78, 1.0)
		else:
			button.self_modulate = Color(0.9, 0.88, 0.84, 1.0)


func _on_base_health_changed(current_health: int, max_health: int) -> void:
	base_health_label.text = "Base HP: %d/%d" % [current_health, max_health]


func _on_enemy_defeated(gold_reward: int) -> void:
	player_currency += gold_reward
	_refresh_hud()
	_show_game_message("Earned %d gold" % gold_reward)


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


func _is_in_battlefield(world_pos: Vector2) -> bool:
	var has_zone := false
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for zone in placement_zones.get_children():
		if not (zone is Area2D):
			continue

		var shape: CollisionShape2D = zone.get_node_or_null("CollisionShape2D")
		if shape == null:
			continue

		var rect_shape := shape.shape as RectangleShape2D
		if rect_shape == null:
			continue

		var half_size := (rect_shape.size * shape.global_scale) / 2.0
		var zone_center := shape.global_position

		min_pos = Vector2(
			minf(min_pos.x, zone_center.x - half_size.x),
			minf(min_pos.y, zone_center.y - half_size.y)
		)
		max_pos = Vector2(
			maxf(max_pos.x, zone_center.x + half_size.x),
			maxf(max_pos.y, zone_center.y + half_size.y)
		)
		has_zone = true

	if not has_zone:
		return true

	var battlefield_rect := Rect2(min_pos, max_pos - min_pos).grow_individual(
		BATTLEFIELD_MARGIN.x,
		BATTLEFIELD_MARGIN.y,
		BATTLEFIELD_MARGIN.x,
		BATTLEFIELD_MARGIN.y
	)
	return battlefield_rect.has_point(world_pos)


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
			_select_tower("cannon")
		elif event.keycode == KEY_2:
			_select_tower("archer")
		elif event.keycode == KEY_3:
			_select_tower("barracks")
		elif event.keycode == KEY_4:
			_select_tower("monastery")
		elif event.keycode == KEY_BACKSPACE:
			# Remove the last placed tower
			if placed_towers.size() > 0:
				var last_tower = placed_towers.pop_back()
				last_tower.queue_free()
				print("Tower removed")
				_show_game_message("Tower removed")
				_refresh_hud()

	# --- TOWER PLACEMENT ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = get_global_mouse_position()

			if not _is_in_battlefield(click_pos):
				return

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
				var insufficient_message := "Not enough coins! Need %d, but have %d." % [cost, player_currency]
				print(insufficient_message)
				_show_game_message(insufficient_message, event.position)
				return

			# If all checks pass - place tower
			player_currency -= cost

			var tower = tower_scenes[selected_tower].instantiate()
			tower.global_position = click_pos
			game_manager.add_child(tower)
			placed_towers.append(tower)

			var placed_message := "Placed: %s (Cost: %d)" % [tower_display_names[selected_tower], cost]
			var currency_message := "Coins left: %d" % player_currency
			print(placed_message, " ", currency_message)
			print(currency_message)
			_show_game_message("%s. %s" % [placed_message, currency_message])
			_refresh_hud()


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
