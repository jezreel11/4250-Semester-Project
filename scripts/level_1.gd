extends Node2D

@export var enemy_scene = preload("res://assets/Animations/LancerRunning.tscn")
@export var enemy_attack = preload("res://assets/Animations/LancerAttacking.tscn")

var tower_scenes = {
	"cannon":    preload("res://scenes/towers/Tower.tscn"),
	"archer":    preload("res://scenes/towers/ArcherTower.tscn"),
	"barracks":  preload("res://scenes/towers/BarracksTower.tscn"),
	"monastery": preload("res://scenes/towers/MonasteryTower.tscn")
}

var selected_tower: String = "cannon"
var placed_towers = []

@onready var placement_zones = $GameManager/Map/PlacementZones

func _ready():
	spawn_enemy()
	print("Tower controls: 1=Cannon  2=Archer  3=Barracks  4=Monastery")
	print("Left click to place | Backspace to undo")

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	$GameManager/Map/Path2D.add_child(enemy)

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
			if _can_place_tower(click_pos) and not _is_occupied(click_pos):
				var tower = tower_scenes[selected_tower].instantiate()
				tower.global_position = click_pos
				add_child(tower)
				placed_towers.append(tower)
				print("Placed: ", selected_tower)
			elif _is_occupied(click_pos):
				print("Too close to another tower!")
			else:
				print("Can't place tower here!")
