extends Camera2D

onready var initial_x = global_position.x
onready var initial_y = global_position.y

var train_is_going = false

func _process(delta: float) -> void:
	global_position = Vector2(initial_x, global_position.y)

	if train_is_going:
		if trauma:
			trauma = max(trauma - decay * delta, 0)
			shake()
		else:
			trauma = 0.5
	else:
		trauma = 0

export var decay = 0.8 # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75) # Maximum hor/ver shake in pixels.
export var max_roll = 0.1 # Maximum rotation in radians (use sparingly).
export(NodePath) var target # Assign the node this camera will follow.

var trauma = 0.2 # Current shake strength.
var trauma_power = 3 # Trauma exponent. Use [2, 3].

func _ready():
	randomize()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range( - 1, 1)
	offset.x = max_offset.x * amount * rand_range( - 1, 1)
	offset.y = max_offset.y * amount * rand_range( - 1, 1)

func _on_Train_train_started() -> void:
	 train_is_going = true

func _on_Train_train_finished(_score) -> void:
	train_is_going = false

func _on_Train_train_start_resting(_resting_time: int) -> void:
	print("resting")
	train_is_going = false

func _on_Train_train_stop_resting() -> void:
	train_is_going = true
