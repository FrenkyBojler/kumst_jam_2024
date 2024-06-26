extends Sprite

var button_icon = preload ("res://textures/ui_dialog_arrow.png")

onready var mayor_image = $MayorControl/MayorImage
onready var mayor_label = $MayorControl/MayerLabel
onready var mayor_text_label = $MayorControl/MayorText

onready var miner_image = $MinerControl/MinerImage
onready var miner_label = $MinerControl/MinerLabel
onready var miner_text_label = $MinerControl/MinerText

onready var how_button = $MinerControl/HowButton
onready var k_button = $MinerControl/KButton
onready var neh_button = $MinerControl/NehButton

const mayor_intro_text = "Dear miner, you have been assigned the utmost urgent task. We need you to go and prepare a way for our brand new SUBWAY."
const mayor_tut_1 = "It’s quite simple, really. All you have to do is to go underground and place as  many rails as you can before the subway arrives."
const mayor_tut_2 = "You can walk using WASD / arrow keys. Walking towards breakable stones also works as mining them."
const mayor_tut_3 = "Furthermore, you can place rails using the F key near the last open rail. Pressing the G key on a last placed rail removes it."
const mayor_tut_4 = "All clear?"
const mayor_ok_text = "Great, now get to work, the subway is ready to go in a while."
const mayor_train_crashed_start = "You did what you could and that’s what counts. You managed to place "
const mayor_train_crashed_finish = " brno-miles of rails before your impending doom. Wanna try again?"
const mayor_pause_speech = "What?! Aren't you supposed to be digging?"

const miner_text = ". . ."

var selected_button_index = 0
onready var buttons = [how_button, k_button, neh_button]

signal mayor_intro_text_finished
signal mayor_tut_1_finished
signal mayor_tut_2_finished
signal mayor_tut_3_finished
signal mayor_tut_4_finished

signal game_started
signal game_paused
signal game_resumed

signal miner_speech_shown
signal mayor_initial_speech_shown

var game_finished := false
var is_game_paused := false

var mayor_active_text = mayor_intro_text

func _ready() -> void:
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_intro_text
	emit_signal("mayor_initial_speech_shown")
	$MajorTalk.play()
	select_button_on_index(true)

var prev_visible = false
	
func _process(_delta: float) -> void:
	if not self.visible and Input.is_action_just_pressed("escape"):
		_pause_game()
	
	if not self.visible:
		return

	if Input.is_action_just_pressed("ui_left"):
		select_prev_button()
	elif Input.is_action_just_pressed("ui_right"):
		select_next_button()
	elif Input.is_action_just_pressed("interact"):
		_interact()

func _interact() -> void:
	$Confirm.play()
	if not $MayorControl/MayorText/MayorTextTimer.is_stopped():
		$MayorControl/MayorText/MayorTextTimer.stop()
		mayor_text_label.visible_characters = -1
		$MayorControl/ArrowNext.visible = true
		$MajorTalk.stop()
	elif $MayorControl/MayorText/MayorTextTimer.is_stopped() and mayor_text_label.get_parent().visible:
		_next_speech()
	elif miner_image.get_parent().visible:
		_push_selected_button()

func _how_button_pressed() -> void:
	_set_mayor_tut_1_speech()
	
func _k_button_pressed() -> void:
	if game_finished:
		_restart_game()
	elif is_game_paused:
		_resume_game()
	else:
		_start_game()
		
func _nah_button_pressed() -> void:
	_exit_game()

func _push_selected_button() -> void:
	if selected_button_index == 0:
		_how_button_pressed()
	if selected_button_index == 1:
		_k_button_pressed()
	if selected_button_index == 2:
		_nah_button_pressed()

func select_next_button() -> void:
	selected_button_index += 1
	if selected_button_index > buttons.size() - 1:
		selected_button_index = 0
	select_button_on_index(false)
	
func select_prev_button() -> void:
	selected_button_index -= 1
	if selected_button_index < 0:
		selected_button_index = buttons.size() - 1
	select_button_on_index(false)

func select_button_on_index(start: bool) -> void:
	for button in buttons:
		(button as ToolButton).icon = null
	(buttons[selected_button_index] as ToolButton).icon = button_icon
	
	if not start:
		$ChangeDialogOption.play()
	
func _resume_game():
	is_game_paused = false
	emit_signal("game_resumed")
	self.hide()

func _pause_game() -> void:
	is_game_paused = true
	emit_signal("game_paused")
	_set_mayor_pause_speech()
	
func _start_game() -> void:
	emit_signal("game_started")
	self.hide()

func _restart_game() -> void:
	var _result = get_tree().reload_current_scene()

func _exit_game() -> void:
	get_tree().quit()

func _on_Timer_timeout() -> void:
	mayor_text_label.visible_characters += 1
	if mayor_text_label.visible_characters == mayor_active_text.length():
		$MayorControl/MayorText/MayorTextTimer.stop()
		$MayorControl/ArrowNext.visible = true
		$MajorTalk.stop()

func _next_speech() -> void:
	$MayorControl/ArrowNext.visible = false
	if mayor_text_label.text == mayor_intro_text:
		emit_signal("mayor_intro_text_finished")
	elif mayor_text_label.text == mayor_tut_1:
		emit_signal("mayor_tut_1_finished")
	elif mayor_text_label.text == mayor_tut_2:
		emit_signal("mayor_tut_2_finished")
	elif mayor_text_label.text == mayor_tut_3:
		emit_signal("mayor_tut_3_finished")
	elif mayor_text_label.text == mayor_tut_4:
		emit_signal("mayor_tut_4_finished")
	else:
		_set_miner_speech()

func _on_SpeechContainer_mayor_intro_text_finished() -> void:
	_set_miner_speech()
	
func _set_miner_speech() -> void:
	emit_signal("miner_speech_shown")
	mayor_image.get_parent().visible = false
	miner_image.get_parent().visible = true
	miner_text_label.text = miner_text
	
func _set_mayor_tut_1_speech() -> void:
	$MajorTalk.play()
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_tut_1
	mayor_active_text = mayor_tut_1
	$MayorControl/MayorText/MayorTextTimer.start()
	mayor_image.get_parent().visible = true
	miner_image.get_parent().visible = false
	
func _set_mayor_tut_2_speech() -> void:
	$MajorTalk.play()
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_tut_2
	mayor_active_text = mayor_tut_2
	$MayorControl/MayorText/MayorTextTimer.start()
	
func _set_mayor_tut_3_speech() -> void:
	$MajorTalk.play()
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_tut_3
	mayor_active_text = mayor_tut_3
	$MayorControl/MayorText/MayorTextTimer.start()
	
func _set_mayor_tut_4_speech() -> void:
	$MajorTalk.play()
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_tut_4
	mayor_active_text = mayor_tut_4
	$MayorControl/MayorText/MayorTextTimer.start()
	
func _set_mayor_train_crash_speech(score) -> void:
	$MajorTalk.play()
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_train_crashed_start + str(score) + mayor_train_crashed_finish
	mayor_active_text = mayor_text_label.text
	$MayorControl/MayorText/MayorTextTimer.start()
	mayor_image.get_parent().visible = true
	miner_image.get_parent().visible = false
	
func _set_mayor_pause_speech() -> void:
	$MajorTalk.play()
	self.visible = true
	mayor_text_label.visible_characters = 0
	mayor_text_label.text = mayor_pause_speech
	mayor_active_text = mayor_text_label.text
	$MayorControl/MayorText/MayorTextTimer.start()
	mayor_image.get_parent().visible = true
	miner_image.get_parent().visible = false

func _on_SpeechContainer_mayor_tut_1_finished() -> void:
	 _set_mayor_tut_2_speech()

func _on_SpeechContainer_mayor_tut_2_finished() -> void:
	 _set_mayor_tut_3_speech()

func _on_SpeechContainer_mayor_tut_3_finished() -> void:
	 _set_mayor_tut_4_speech()

func _on_ChangeSpeechTimer_timeout() -> void:
	pass # Replace with function body.

func _on_SpeechContainer_mayor_tut_4_finished() -> void:
	_set_miner_speech()

func _on_Train_train_finished(score) -> void:
	yield (get_tree().create_timer(2), "timeout")
	game_finished = true
	self.visible = true
	_set_mayor_train_crash_speech(score)

func _on_HowButton_button_down() -> void:
	$Confirm.play()
	_how_button_pressed()

func _on_KButton_button_down() -> void:
	$Confirm.play()
	_k_button_pressed()

func _on_NehButton_button_down() -> void:
	$Confirm.play()
	_nah_button_pressed()

func _on_SwipeJoystick_touched() -> void:
	if self.visible:
		_interact()

func _on_MenuButton_game_paused_from_menu_button() -> void:
	_pause_game()
