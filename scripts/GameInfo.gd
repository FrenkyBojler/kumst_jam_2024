extends Control

const GAME_INFO_LABEL_PREFIX = "Train status: "
const GAME_INFO_DEPARTS_LABEL_PREFIX = "Departure in "
const GAME_INFO_TRAIN_GOING_TO_LABEL_PREFIX = "Train is moving"
const GAME_INFO_TRAIN_STOPPED_LABEL_PREFIX = "Train stopped for "
const GAME_INFO_PRESS_F_TO_INTERACT = "Press F to interact"
const GAME_INFO_USE_ARROWS_TO_CHOOSE = "Use arrows to choose"

onready var label = $Label
onready var animation_player = $AnimationPlayer

const TRAIN_START_TIME = 20 # seconds
var train_start_countdown = 0 # seconds
var train_resting_time = 0 # seconds
var train_current_resting_time = 0 # seconds

var can_show_tiles_to_rest := false

var numer_of_tiles_traveled := 0

var is_label_visible := false

var has_game_started := false

var train_started := false

signal train_start

func _on_TrainStartTimer_timeout() -> void:
	train_start_countdown += 1

	if train_start_countdown >= TRAIN_START_TIME:
		_train_start()
	else:
		_set_train_starts_in_info_label()

func _train_start() -> void:
	train_started = true
	train_start_countdown = 0
	$TrainStartTimer.stop()
	emit_signal("train_start")

func _set_train_starts_in_info_label() -> void:
	var game_info = ""
	game_info += GAME_INFO_DEPARTS_LABEL_PREFIX + str(TRAIN_START_TIME - train_start_countdown) + " seconds"
	label.text = game_info

func _on_SpeechContainer_game_started() -> void:
	has_game_started = true
	$TrainStartTimer.start()
	_set_train_starts_in_info_label()
	_show_label()

func _on_Train_train_started() -> void:
	_show_train_is_moving()

var wait_to_show_resting_time_seconds := 3
var is_resting := false
var is_paused := false

func _on_Train_train_start_resting(rest_time: int) -> void:
	wait_to_show_resting_time_seconds = 3
	is_resting = true
	_hide_label()
	if is_paused:
		wait_to_show_resting_time_seconds = 0
		return
	yield(get_tree().create_timer(wait_to_show_resting_time_seconds), "timeout")
	if is_paused:
		return
	$TrainRestingTimer.start()
	train_resting_time = rest_time
	label.text = GAME_INFO_DEPARTS_LABEL_PREFIX + str(train_resting_time - wait_to_show_resting_time_seconds - train_current_resting_time) + " seconds"
	_show_label()

func _on_Train_train_stop_resting() -> void:
	is_resting = false
	$TrainRestingTimer.stop()
	_show_train_is_moving()
	train_current_resting_time = 0

func _on_Train_train_finished(_score: int) -> void:
	pass # Replace with function body.

func _on_TrainRestingTimer_timeout() -> void:
	train_current_resting_time += 1
	label.text = GAME_INFO_DEPARTS_LABEL_PREFIX + str(train_resting_time - wait_to_show_resting_time_seconds - train_current_resting_time) + " seconds"

func _on_Train_tile_changed(_tile: Vector2, tiles_to_rest: int) -> void:
	if tiles_to_rest <= 15 and train_started:
		_show_label()
		label.text = "Train will stop in " + str(tiles_to_rest) + " tiles"

func _on_ShowTilesToRest_timeout() -> void:
	can_show_tiles_to_rest = true

func _show_train_is_moving() -> void:
	_show_label()
	label.text = GAME_INFO_TRAIN_GOING_TO_LABEL_PREFIX
	yield(get_tree().create_timer(5), "timeout")
	_hide_label()

func _show_label() -> void:
	if is_label_visible:
		return
	is_label_visible = true
	animation_player.play("Show")

func _hide_label() -> void:
	if not is_label_visible:
		return
	animation_player.play("Hide")
	is_label_visible = false

func _wipe_lable() -> void:
	label.text = ""


func _show_press_f_to_interact() -> void:
	if has_game_started:
		return
	label.text = GAME_INFO_PRESS_F_TO_INTERACT
	_show_label()
	yield(get_tree().create_timer(5), "timeout")
	if has_game_started:
		return
	_hide_label()
	yield(get_tree().create_timer(1), "timeout")
	_show_use_arrows_to_choose()

func _show_use_arrows_to_choose() -> void:
	if has_game_started:
		return
	label.text = GAME_INFO_USE_ARROWS_TO_CHOOSE
	_show_label()
	yield(get_tree().create_timer(5), "timeout")
	if has_game_started:
		return
	_hide_label()

func _on_SpeechContainer_mayor_initial_speech_shown():
	_show_press_f_to_interact()

func _on_SpeechContainer_game_resumed():
	is_paused = false
	if is_resting:
		$TrainRestingTimer.paused = false
		_show_label()

	if $TrainStartTimer.time_left != TRAIN_START_TIME:
		$TrainStartTimer.paused = false
		_set_train_starts_in_info_label()
		_show_label()


func _on_SpeechContainer_game_paused():
	is_paused = true
	if is_resting:
		_hide_label()
		$TrainRestingTimer.paused = true
	if $TrainStartTimer.time_left != TRAIN_START_TIME:
		_hide_label()
		$TrainStartTimer.paused = true

