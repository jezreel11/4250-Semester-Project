extends Node2D

@export var enemy_scene = preload("res://assets/Animations/Lancer.tscn")

@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")
@onready var placement_zones = $GameManager/Map/PlacementZones

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
var selected_tower = "cannon"
var player_currency: int = 500

@export var wave_size: int = 5
@export var spawn_interval: float = 2.0
var enemies_spawned: int = 0
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

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

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			selected_tower = "cannon"
			print("Selected: Cannon Tower")
		elif event.keycode == KEY_2:
			selected_tower = "archer"
			print("Selected: Archer Tower")
		elif event.keycode == KEY_3:
			selected_tower = "barracks"
			print("Selected: Barracks")
		elif event.keycode == KEY_4:
			selected_tower = "monastery"
			print("Selected: Monastery")
		elif event.keycode == KEY_BACKSPACE:
			if placed_towers.size() > 0:
				var last_tower = placed_towers.pop_back()
				last_tower.queue_free()
				print("Tower removed")

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = get_global_mouse_position()

			if not _can_place_tower(click_pos):
				print("Can't place tower here!")
				return

			if _is_occupied(click_pos):
				print("Too close to another tower!")
				return

			var cost = tower_costs[selected_tower]
			if player_currency < cost:
				print("Not enough currency! Need ", cost, ", have ", player_currency)
				return

			player_currency -= cost
			var tower = tower_scenes[selected_tower].instantiate()
			tower.global_position = click_pos
			add_child(tower)
			placed_towers.append(tower)
			tower.path_node = $GameManager/Map/Path2D
			print("Placed: ", selected_tower, " | Cost: ", cost, " | Currency left: ", player_currency)