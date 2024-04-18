extends Node2D

onready var trains = get_children()

func _on_GameInfo_train_start() -> void:
	for train in trains:
		(train as Train)._on_StartTrainTimer_timeout()
