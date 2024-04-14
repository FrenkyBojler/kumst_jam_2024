extends Node2D

export(NodePath) var target_path
onready var target = get_node(target_path) as Node2D

onready var initial_y_difference = global_position.y - target.global_position.y
onready var initial_x_difference = global_position.y - target.global_position.x

func _process(_delta: float) -> void:
	global_position = Vector2(target.global_position.x + initial_x_difference, target.global_position.y + initial_y_difference)
