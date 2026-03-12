extends Node2D

# test committing changes
@onready var tower_scene = preload("res://scenes/towers/Tower.tscn")
var placed_towers = []  # tracks all placed towers

func _input(event):
	# Left click — place a tower
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var tower = tower_scene.instantiate()
			tower.global_position = get_global_mouse_position()
			add_child(tower)
			placed_towers.append(tower)  # add to tracking list

	# Backspace — remove the last placed tower
	if event is InputEventKey:
		if event.keycode == KEY_BACKSPACE and event.pressed:
			if placed_towers.size() > 0:
				var last_tower = placed_towers.pop_back()  # removes from list
				last_tower.queue_free()                    # removes from scene
