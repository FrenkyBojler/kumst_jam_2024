extends KinematicBody2D

class_name Player

export(NodePath) var tile_map_path
onready var tile_map = get_node(tile_map_path) as TileMapGenerator

export(NodePath) var tile_map_interaction_path
onready var tile_map_interaction = get_node(tile_map_interaction_path) as Tiles

export(NodePath) var tile_map_rails_path
onready var tile_map_rails = get_node(tile_map_rails_path) as Tiles

onready var left_collision: Area2D = $LeftCollision
onready var right_collision: Area2D = $RightCollision
onready var top_collision: Area2D = $TopCollision
onready var bottom_collision: Area2D = $BottomCollision

onready var light_left: Light2D = $LightLeft
onready var light_right: Light2D = $LightRight
onready var light_up: Light2D = $LightUp
onready var light_down: Light2D = $LightDown

onready var drill_timer: Timer = $DrillTimer
onready var remove_rail_timer: Timer = $RemoveRailTimer

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_velocity := Vector2.ZERO
var rotation_dir = 0
var speed := 100.0
var rotation_speed := 5.0

var interaction_mode = true

var last_interaction_pos: Vector2
var last_placed_rail_pos: Vector2

var max_drill_timer = 0.1
var current_drill_time = 0

#Vector2D
var left_interaction_cell_pos
var right_interaction_cell_pos
var top_interaction_cell_pos
var bottom_interaction_cell_pos

#Vector2D
var currently_drilled_cell_pos
var currently_drilling_pos

var is_left_pressed: bool
var is_right_pressed: bool
var is_up_pressed: bool
var is_down_pressed: bool

const max_rotation_left= 270
const max_rotation_right = 90
const max_rotation_top = 0
const max_rotation_bottom = 180

var is_drilling := false

var is_touching := false
var is_left_touching := false
var is_right_touching := false
var is_down_touching := false
var is_up_touching := false

func _process(delta: float) -> void:
	_movement_input()
	_check_actions_released()
	_place_rail_input()
	_move_by_current_velocity(delta)
	_check_stop_drill_by_action_released()

func _movement_input() -> void:
	rotation_dir = 0
	if not is_touching:
		if Input.is_action_pressed("ui_left"):
			is_left_pressed = true
			current_velocity = Vector2.LEFT
		elif Input.is_action_pressed("ui_right"):
			is_right_pressed = true
			current_velocity = Vector2.RIGHT
		elif Input.is_action_pressed("ui_down"):
			is_down_pressed = true
			current_velocity = Vector2.DOWN
		elif Input.is_action_pressed("ui_up"):
			is_up_pressed = true
			current_velocity = Vector2.UP
		else:
			current_velocity = Vector2.ZERO

	if not is_drilling:
		_play_run_anim()

func _check_actions_released() -> void:
	if Input.is_action_just_released("ui_left"):
		is_left_pressed = false
	if Input.is_action_just_released("ui_right"):
		is_right_pressed = false
	if Input.is_action_just_released("ui_up"):
		is_up_pressed = false
	if Input.is_action_just_released("ui_down"):
		is_down_pressed = false

func _move_by_current_velocity(delta: float) -> void:
	var cols = move_and_collide(current_velocity * delta * speed)
	_check_wall_collision(cols)

func _check_wall_collision(collision: KinematicCollision2D) -> void:
	if collision != null:
		var current_wall_cell_pos = _get_interaction_cell_by_direction(current_velocity)
		if current_wall_cell_pos != null and tile_map.is_wall_tile(current_wall_cell_pos) and currently_drilled_cell_pos != current_wall_cell_pos:
			currently_drilled_cell_pos = current_wall_cell_pos
			currently_drilling_pos = current_velocity
			_start_drill()

func _start_drill() -> void:
	animation_player.play("Drill")
	_reset_drill_timer()
	drill_timer.start()
	is_drilling = true

# Vector2 or null
func _check_stop_drill(pos) -> void:
	if pos == currently_drilled_cell_pos:
		_stop_drill()

func _stop_drill() -> void:
	_reset_drill_timer()
	_play_idle_anim()
	currently_drilled_cell_pos = null
	currently_drilling_pos = null
	is_drilling = false

func _reset_drill_timer() -> void:
	drill_timer.stop()
	current_drill_time = 0.0

func _drill_progress() -> void:
	current_drill_time += 1
	if current_drill_time >= max_drill_timer:
		tile_map.place_ground(currently_drilled_cell_pos)
		_stop_drill()

func _check_stop_drill_by_action_released() -> void:
	if currently_drilling_pos == Vector2.LEFT and !is_left_pressed and !is_left_touching:
		_stop_drill()
	elif currently_drilling_pos == Vector2.RIGHT and !is_right_pressed and !is_right_touching:
		_stop_drill()
	elif currently_drilling_pos == Vector2.UP and !is_up_pressed and !is_up_touching:
		_stop_drill()
	elif currently_drilling_pos == Vector2.DOWN and !is_down_pressed and !is_down_touching:
		_stop_drill()
		
func _get_collision_position_of_drilling() -> Vector2:
	return _get_interaction_cell_by_direction(currently_drilled_cell_pos)	

func _get_interaction_cell_by_direction(direction: Vector2):
	var col_pos: Vector2
	if direction == Vector2.LEFT:
		col_pos = left_collision.global_position
	elif direction == Vector2.RIGHT:
		col_pos = right_collision.global_position
	elif direction == Vector2.UP:
		col_pos = top_collision.global_position
	elif direction == Vector2.DOWN:
		col_pos = bottom_collision.global_position
	else:
		return null
	return tile_map.world_to_map(col_pos)
 
func _place_rail_input() -> void:
	if interaction_mode:
		_place_ghost_rail()

	if Input.is_action_just_pressed("interact"):
		_trigger_place_rail()
		remove_rail_timer.start()
		
	if Input.is_action_just_released("interact"):
		remove_rail_timer.stop()

func _trigger_place_rail() -> void:
	if not interaction_mode:
		interaction_mode = true
	else:
		_place_rail()

func _place_rail() -> void:
	tile_map_interaction.place_ground(last_interaction_pos)
	var last_placed_rail_pos_backup = last_placed_rail_pos
	last_placed_rail_pos = tile_map_rails.world_to_map(global_position)
	tile_map_rails.place_rails(last_placed_rail_pos)
	if last_placed_rail_pos_backup != null:
		tile_map_rails.update_autotile_for_cel(last_placed_rail_pos_backup)
	
func _place_ghost_rail() -> void:
	if last_interaction_pos != null:
		tile_map_interaction.place_ground(last_interaction_pos)
	
	last_interaction_pos = tile_map_interaction.world_to_map(global_position)
	tile_map_interaction.place_ghost_rail(last_interaction_pos)

func _on_DrillTimer_timeout() -> void:
	_drill_progress()
	
func _turn_off_lights() -> void:
	light_left.visible = false
	light_right.visible = false
	light_up.visible = false
	light_down.visible = false

func _play_idle_anim() -> void:
	if current_velocity == Vector2.LEFT:
		_turn_off_lights()
		light_left.visible = true
		animation_player.play("IdleLeft")
	if current_velocity == Vector2.RIGHT:
		_turn_off_lights()
		light_right.visible = true
		animation_player.play("IdleRight")
	if current_velocity == Vector2.DOWN:
		_turn_off_lights()
		light_down.visible = true
		animation_player.play("IdleDown")
	if current_velocity == Vector2.UP:
		_turn_off_lights()
		light_up.visible = true
		animation_player.play("IdleUp")
	if current_velocity == Vector2.ZERO:
		_turn_off_lights()
		light_up.visible = true
		animation_player.play("IdleUp")
		
func _play_run_anim() -> void:
	if current_velocity == Vector2.LEFT:
		_turn_off_lights()
		light_left.visible = true
		animation_player.play("IdleLeft")
	if current_velocity == Vector2.RIGHT:
		_turn_off_lights()
		light_right.visible = true
		animation_player.play("IdleRight")
	if current_velocity == Vector2.DOWN:
		_turn_off_lights()
		light_down.visible = true
		animation_player.play("IdleDown")
	if current_velocity == Vector2.UP:
		_turn_off_lights()
		light_up.visible = true
		animation_player.play("IdleUp")

func _on_SwipeJoystick_swipe_down(speed) -> void:
	if speed != Vector2.ZERO:
		_turn_off_touching()
		is_touching = true
		is_up_touching = true
		current_velocity = Vector2.UP

func _on_SwipeJoystick_swipe_left(speed) -> void:
	if speed != Vector2.ZERO:
		_turn_off_touching()
		is_touching = true
		is_left_touching = true
		current_velocity = Vector2.LEFT

func _on_SwipeJoystick_swipe_right(speed) -> void:
	if speed != Vector2.ZERO:
		_turn_off_touching()	
		is_touching = true
		is_right_touching = true
		current_velocity = Vector2.RIGHT

func _on_SwipeJoystick_swipe_top(speed) -> void:
	if speed != Vector2.ZERO:
		_turn_off_touching()
		is_touching = true
		is_down_touching = true
		current_velocity = Vector2.DOWN
		
func _turn_off_touching() -> void:
	is_right_touching = false
	is_left_touching = false
	is_up_touching = false
	is_down_touching = false

func _on_SwipeJoystick_touched() -> void:
	_trigger_place_rail()

func _on_SwipeJoystick_touch_released() -> void:
	current_velocity = Vector2.ZERO
	_turn_off_touching()
	is_touching = false
	
func _turn_off_all_lights() -> void:
	for child in get_children():
		if child is Light2D:
			child.enabled = false

func _on_RemoveRailTimer_timeout() -> void:
	tile_map_rails.remove_rail(tile_map_rails.world_to_map(global_position))
	
func _on_Train_train_finished() -> void:
	_turn_off_all_lights()
