@tool
extends Node2D

# arbitrary code execution from the editor

@export var run = false:
	set(value):
		run_code()


func run_code():
	print('hede')

