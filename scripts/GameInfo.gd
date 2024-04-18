extends Control

const GAME_INFO_LABEL_PREFIX = "Train status: "
const GAME_INFO_DEPARTS_LABEL_PREFIX = "Departure in "
const GAME_INFO_TRAIN_GOING_TO_LABEL_PREFIX = "Train is moving"
const GAME_INFO_TRAIN_STOPPED_LABEL_PREFIX = "Train stopped for "

onready var label = $Label

const TRAIN_START_TIME = 20 # seconds
var train_start_countdown = 0 # seconds
var train_resting_time = 0 # seconds
var train_current_resting_time = 0 # seconds

var can_show_tiles_to_rest := false

signal train_start

func _on_TrainStartTimer_timeout() -> void:
	train_start_countdown += 1

	if train_start_countdown >= TRAIN_START_TIME:
		_train_start()
	else:
		_set_train_starts_in_info_label()

func _train_start() -> void:
	train_start_countdown = 0
	$TrainStartTimer.stop()
	emit_signal("train_start")

func _set_train_starts_in_info_label() -> void:
	var game_info = ""
	game_info += GAME_INFO_DEPARTS_LABEL_PREFIX + str(TRAIN_START_TIME - train_start_countdown) + " seconds"
	label.text = game_info

func _on_SpeechContainer_game_started() -> void:
	$TrainStartTimer.start()
	_set_train_starts_in_info_label()

func _on_Train_train_started() -> void:
	label.text = GAME_INFO_TRAIN_GOING_TO_LABEL_PREFIX
	$ShowTilesToRest.start()

func _on_Train_train_start_resting(rest_time: int) -> void:
	train_resting_time = rest_time
	$TrainRestingTimer.start()
	label.text = GAME_INFO_TRAIN_STOPPED_LABEL_PREFIX + str($TrainRestingTimer.time_left) + " seconds"
	can_show_tiles_to_rest = false

func _on_Train_train_stop_resting() -> void:
	$TrainRestingTimer.stop()
	label.text = GAME_INFO_TRAIN_GOING_TO_LABEL_PREFIX
	$ShowTilesToRest.start()

func _on_Train_train_finished(_score: int) -> void:
	pass # Replace with function body.

func _on_TrainRestingTimer_timeout() -> void:
	train_current_resting_time += 1
	label.text = GAME_INFO_TRAIN_STOPPED_LABEL_PREFIX + str(train_resting_time - train_current_resting_time) + " seconds"

func _on_Train_tile_changed(_tile: Vector2, tiles_to_rest: int) -> void:
	if can_show_tiles_to_rest:
		label.text = "Train will stop in " + str(tiles_to_rest) + " tiles"

func _on_ShowTilesToRest_timeout() -> void:
	can_show_tiles_to_rest = true
