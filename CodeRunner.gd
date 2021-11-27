tool
extends Node2D

# arbitrary code execution from the editor

export var run = false setget run_code


func run_code(run):
	print('run')
