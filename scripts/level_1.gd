extends Node2D

# Preloading the enemy scenes
@export var enemy_scene = preload("res://assets/Animations/LancerRunning.tscn")
@export var enemy_attack = preload("res://assets/Animations/LancerAttacking.tscn")

# Preload Towers for placement
var tower_scenes = {
	"cannon":    preload("res://scenes/towers/Tower.tscn"),
	"archer":    preload("res://scenes/towers/ArcherTower.tscn"),
	"barracks":  preload("res://scenes/towers/BarracksTower.tscn"),
	"monastery": preload("res://scenes/towers/MonasteryTower.tscn")
}

var tower_costs = {
	"cannon": 100,
	"archer": 175,
	"barracks": 225,
	"monastery": 300
}

var placed_towers = []
var player_currency: int = 100
var dragging_tower: String = ""

@onready var placement_zones = $GameManager/Map/PlacementZones

# --- WAVE SETTINGS ---
@export var wave_size: int = 5
@export var spawn_interval: float = 2.0
var enemies_spawned: int = 0
var spawn_timer: Timer

func _ready():
	# Set up wave timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

	# Build the sidebar UI
	_build_sidebar()

func _on_spawn_timer_timeout():
	if enemies_spawned < wave_size:
		spawn_enemy()
		enemies_spawned += 1
	else:
		spawn_timer.stop()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	$GameManager/Map/Path2D.add_child(enemy)
	enemy.lane_index = enemies_spawned

# --- SIDEBAR UI ---
func _build_sidebar():
	var canvas = CanvasLayer.new()
	add_child(canvas)

	var panel = PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -140
	canvas.add_child(panel)

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Towers"
	vbox.add_child(title)

	for key in tower_scenes.keys():
		var btn = Button.new()
		btn.text = "%s ($%d)" % [key.capitalize(), tower_costs[key]]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_on_tower_button_pressed.bind(key))
		vbox.add_child(btn)


# --- TOWER SELECTION & PLACEMENT ---
func _on_tower_button_pressed(tower_key: String):
	dragging_tower = tower_key
	print("Selected: ", tower_key, " — click on map to place, right-click to cancel")


func _input(event):
	if dragging_tower == "":
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = get_global_mouse_position()
			_try_place_tower(click_pos)
			dragging_tower = ""
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			dragging_tower = ""
			print("Cancelled placement")


func _try_place_tower(world_pos: Vector2):
	if not _can_place_tower(world_pos):
		print("Can't place tower here!")
		return

	if _is_occupied(world_pos):
		print("Too close to another tower!")
		return

	var cost = tower_costs[dragging_tower]
	if player_currency < cost:
		print("Not enough currency! Need ", cost, ", have ", player_currency)
		return

	player_currency -= cost
	var tower = tower_scenes[dragging_tower].instantiate()
	tower.global_position = world_pos
	add_child(tower)
	placed_towers.append(tower)
	print("Placed: ", dragging_tower, " | Cost: ", cost, " | Currency left: ", player_currency)


func _can_place_tower(world_pos: Vector2) -> bool:
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
	for tower in placed_towers:
		if is_instance_valid(tower):
			if tower.global_position.distance_to(world_pos) < 70.0:
				return true
	return false
