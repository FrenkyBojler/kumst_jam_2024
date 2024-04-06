extends Camera2D

onready var initial_x = global_position.x
onready var initial_y = global_position.y


func _process(_delta: float) -> void:
	global_position = Vector2(initial_x, global_position.y)
