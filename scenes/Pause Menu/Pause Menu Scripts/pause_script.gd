extends Node

# Main pause menu container
@export var container_Main: Control

# Buttons
@export var button_Resume: Button
@export var button_Restart: Button
@export var button_MainMenu: Button
@export var screen_MainMenu: PackedScene
@export var button_Quit: Button
@export var key_Resume: Key = KEY_ESCAPE


const PAUSE_ACTION = "_pause_toggle"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	container_Main.process_mode = Node.PROCESS_MODE_ALWAYS
	container_Main.visible = false
	_setup_pause_key()

	# Connect buttons to functions
	button_Resume.pressed.connect(resume_game)
	button_Restart.pressed.connect(restart_level)
	button_MainMenu.pressed.connect(go_to_main_menu)
	button_Quit.pressed.connect(quit_game)

	# Connect to base game over signal
	var base = get_tree().root.get_node_or_null("Level1/GameManager/Map/Base")
	if base:
		base.game_over.connect(_on_game_over)


func _on_game_over():
	pause_game()


func _setup_pause_key():
	if InputMap.has_action(PAUSE_ACTION):
		InputMap.action_erase_events(PAUSE_ACTION)
	else:
		InputMap.add_action(PAUSE_ACTION)
	var ev = InputEventKey.new()
	ev.keycode = key_Resume
	InputMap.action_add_event(PAUSE_ACTION, ev)


func _process(_delta):
	if Input.is_action_just_pressed(PAUSE_ACTION):
		toggle_pause()


func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()


func pause_game():
	get_tree().paused = true
	container_Main.visible = true


func resume_game():
	get_tree().paused = false
	container_Main.visible = false

func restart_level():
	get_tree().reload_current_scene()

func go_to_main_menu():
	get_tree().change_scene_to_packed(screen_MainMenu)

func quit_game():
	get_tree().quit()

	
