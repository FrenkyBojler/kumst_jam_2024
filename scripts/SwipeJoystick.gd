extends Area2D

export (NodePath) var richt_text_path
onready var rich_text_node = get_node_or_null(richt_text_path)

const CHANGE_DIRECTION_THRESHOLD = 5
var initial_touch_position = Vector2.ZERO

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			initial_touch_position = event.position
			print("Touched")
			#_print_out_gesture("Touched")
			_reset_swipes()
			emit_signal("touched")
		if !event.is_pressed():
			initial_touch_position = Vector2.ZERO
			print("Released")
			#_print_out_gesture("Released")
			_reset_swipes()
			emit_signal("touch_released")
	if event is InputEventScreenDrag:
		if event.position.x < initial_touch_position.x and abs(event.position.x - initial_touch_position.x) > CHANGE_DIRECTION_THRESHOLD:
			print("Swipe Left -  " + str(abs(event.position.x - initial_touch_position.x)))
			#_print_out_gesture("Swipe Left -  " + str(abs(event.position.x - initial_touch_position.x)))
			emit_signal("swipe_left", event.speed.floor())
		elif event.position.x > initial_touch_position.x and abs(event.position.x - initial_touch_position.x) > CHANGE_DIRECTION_THRESHOLD:
			print("Swipe Right - " + str(abs(event.position.x - initial_touch_position.x)))
			#_print_out_gesture("Swipe right -  " + str(abs(event.position.x - initial_touch_position.x)))
			emit_signal("swipe_right", event.speed.floor())
		elif event.position.y > initial_touch_position.y and abs(event.position.y -initial_touch_position.y) > CHANGE_DIRECTION_THRESHOLD:
			print("Swipe Up - " + str(abs(event.position.y - initial_touch_position.y)))
			emit_signal("swipe_top", event.speed.floor())
		elif event.position.y < initial_touch_position.y and abs(event.position.y -initial_touch_position.y) > CHANGE_DIRECTION_THRESHOLD:
			print("Swipe Down - " + str(abs(event.position.y - initial_touch_position.y)))
			emit_signal("swipe_down", event.speed.floor())
		else:
			_reset_swipes()
		initial_touch_position = event.position

func _reset_swipes():
	emit_signal("swipe_left", Vector2.ZERO)
	emit_signal("swipe_right", Vector2.ZERO)
	emit_signal("swipe_down", Vector2.ZERO)
	emit_signal("swipe_top", Vector2.ZERO)

func _print_out_gesture(gesture, value = null):
	if rich_text_node != null and value != null:
		rich_text_node.set_text(gesture + " - " + str(value))
	elif rich_text_node != null and value == null:
		rich_text_node.set_text(gesture)

#Signals
signal swipe_left(speed)
signal swipe_right(speed)
signal swipe_top(speed)
signal swipe_down(speed)
signal touched
signal touch_released
