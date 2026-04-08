extends Node

# Main pause menu container
@export var container_Main: Control

# Buttons
@export var button_Resume: Button
@export var button_Settings: Button
@export var button_Restart: Button
@export var button_MainMenu: Button
@export var screen_MainMenu: NavigationLink2D
@export var button_Quit: Button

# Settings submenu (you will add this later)
@export var container_Settings: Control


func _ready() -> void:
	container_Main.visible = false
	container_Settings.visible = false

	# Connect buttons
	button_Resume.pressed.connect(resume_game)
	button_Settings.pressed.connect(open_settings)
	button_Restart.pressed.connect(restart_level)
	button_MainMenu.pressed.connect(go_to_main_menu)
	button_Quit.pressed.connect(quit_game)


func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		toggle_pause()


func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()


func pause_game():
	get_tree().paused = true
	container_Main.visible = true
	container_Settings.visible = false


func resume_game():
	get_tree().paused = false
	container_Main.visible = false
	container_Settings.visible = false


func open_settings():
	container_Main.visible = false
	container_Settings.visible = true


func restart_level():
	get_tree().reload_current_scene()


func go_to_main_menu():
	screen_MainMenu.navigate_to()


func quit_game():
	get_tree().quit()

	
