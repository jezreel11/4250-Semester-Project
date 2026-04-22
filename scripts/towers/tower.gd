class_name CannonTower
extends BaseTower

var projectile_script = preload("res://scripts/projectile.gd")
var shoot_timer: Timer

func _ready():
	tower_name = "Cannon Tower"
	damage = 34
	fire_rate = 2.0
	attack_range = 150.0
	cost = 200
	super._ready()

	shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0 / fire_rate
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer)
	add_child(shoot_timer)


func _on_shoot_timer():
	var enemy = _find_nearest_enemy()
	if enemy:
		print("Cannon Tower firing at enemy!")
		_shoot(enemy)


func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = attack_range

	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = e

	return nearest


func _shoot(enemy: Node2D):
	var proj = Node2D.new()
	proj.set_script(projectile_script)
	proj.global_position = global_position
	proj.set("damage", damage)
	get_parent().add_child(proj)
	proj.set("target", enemy)


func _draw():
	draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 1, 0.1))
	super._draw()
