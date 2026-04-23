extends Node

# Main pause menu container
@export var container_Main: Control

# Buttons
@export var button_Resume: Button
@export var button_Restart: Button
@export var button_MainMenu: Button
@export var button_Fullscreen: Button
@export var button_Quit: Button
@export var key_Resume: Key = KEY_ESCAPE
@export var key_Fullscreen: Key = KEY_F11


const PAUSE_ACTION = "_pause_toggle"
const FULLSCREEN_ACTION = "_fullscreen_toggle"
const BASE_PATH = "Level1/GameManager/Map/Base"

var _connected_base: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	container_Main.process_mode = Node.PROCESS_MODE_ALWAYS
	container_Main.visible = false
	_setup_pause_key()
	_setup_fullscreen_key()

	# Connect buttons to functions
	button_Resume.pressed.connect(resume_game)
	button_Restart.pressed.connect(restart_level)
	button_MainMenu.pressed.connect(go_to_main_menu)
	button_Fullscreen.pressed.connect(toggle_fullscreen)
	button_Quit.pressed.connect(quit_game)
	_update_fullscreen_button_text()
	get_tree().node_added.connect(_on_tree_node_added)

	# Connect to the active level base whenever it becomes available.
	call_deferred("_connect_to_base_if_available")


func _on_game_over():
	pause_game()


func _on_tree_node_added(_node: Node) -> void:
	_connect_to_base_if_available()


func _connect_to_base_if_available() -> void:
	var base := get_tree().root.get_node_or_null(BASE_PATH)
	if base == null or base == _connected_base:
		return
	if _connected_base and _connected_base.game_over.is_connected(_on_game_over):
		_connected_base.game_over.disconnect(_on_game_over)
	base.game_over.connect(_on_game_over)
	_connected_base = base


func _setup_pause_key():
	if InputMap.has_action(PAUSE_ACTION):
		InputMap.action_erase_events(PAUSE_ACTION)
	else:
		InputMap.add_action(PAUSE_ACTION)
	var ev = InputEventKey.new()
	ev.keycode = key_Resume
	InputMap.action_add_event(PAUSE_ACTION, ev)


func _setup_fullscreen_key():
	if InputMap.has_action(FULLSCREEN_ACTION):
		InputMap.action_erase_events(FULLSCREEN_ACTION)
	else:
		InputMap.add_action(FULLSCREEN_ACTION)
	var ev = InputEventKey.new()
	ev.keycode = key_Fullscreen
	InputMap.action_add_event(FULLSCREEN_ACTION, ev)


func _process(_delta):
	if Input.is_action_just_pressed(PAUSE_ACTION):
		toggle_pause()
	if Input.is_action_just_pressed(FULLSCREEN_ACTION):
		toggle_fullscreen()


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
	get_tree().change_scene_to_file("res://mainmenu.tscn")


func toggle_fullscreen():
	var window := get_window()
	if window.mode == Window.MODE_FULLSCREEN:
		window.mode = Window.MODE_WINDOWED
	else:
		window.mode = Window.MODE_FULLSCREEN
	_update_fullscreen_button_text()


func _update_fullscreen_button_text():
	if button_Fullscreen == null:
		return
	var is_fullscreen := get_window().mode == Window.MODE_FULLSCREEN
	button_Fullscreen.text = "Windowed Mode" if is_fullscreen else "Fullscreen Mode"


func quit_game():
	get_tree().quit()

	
