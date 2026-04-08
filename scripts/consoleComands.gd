extends Node

# Add console custom comands here

# Adds the comand to the console list
func _ready() -> void:
	# for names sake try to follow the naming conventions below
	# below is a example of how to add a comand to the console
	# the "example_comand" is what you type in the console in game
	# and the console_exampleComand is the name of the fuction that gets called.
	Console.add_command("example_comand", console_exampleComand)

# This is the function used in the example comand in the console
func console_exampleComand():
	Console.print_line("comand ran")
