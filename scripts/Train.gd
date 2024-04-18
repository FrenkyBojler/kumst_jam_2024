extends KinematicBody2D

class_name Train

export(NodePath) var player_path
onready var player = get_node(player_path)

export(NodePath) var rail_tile_map_path
onready var rail_tile_map = get_node(rail_tile_map_path) as TileMap

export(NodePath) var real_tile_map_path
onready var real_tile_map = get_node(real_tile_map_path) as TileMap

var nav_path: PoolVector2Array

var current_velocity: Vector2 = Vector2.ZERO
var speed := 60.0

var rai_cell_id = 0
var finish_cell_id = 3
var start_cell_id = 2

var start_cell_coord: Vector2
var finish_cell_coord: Vector2
var rail_cells_coords: PoolVector2Array

var last_cell_coords: Vector2

#Vector2 or Null
var target_pos

var path: PoolVector2Array

signal tile_changed(tile, tiles_to_rest)
signal train_finished(score)
signal train_started
signal train_start_resting(time)
signal train_stop_resting

const top_right_corner := 0
const horizontal := 1
const top_left_corner := 2
const vertical := 3
const bottom_right_corner := 4
const bottom_left_corner := 5

onready var default_position := global_position

export(bool) var is_leading_train = false

var tiles_traveled := 0
var stop_after_tiles_traveled := 50
var score := 0

var train_resting_time := 10

var is_paused := true
#indicates if the train is at the start of the game
var is_start_of_game := true

var is_train_in_motion := false

func _ready() -> void:
	if is_leading_train:
		$Humming.play()

func _start_resting() -> void:
	is_paused = true
	$RestTrainTimer.start(train_resting_time)
	emit_signal("train_start_resting", train_resting_time)
	
func _start_train() -> void:
	emit_signal("train_started")
	global_position = default_position
	#path = rail_tile_map.path
	if path.size() == 0:
		_train_crashed("start_train")
		return
	
	target_pos = _get_correct_world_coord(path[0])

func _get_path() -> PoolVector2Array:
	var start_coord = _get_lowest_rail_coord()
	var finish_coord = rail_tile_map.get_used_cells_by_id(7)[0]
	var rails = rail_tile_map.get_used_cells_by_id(top_right_corner)
	rails.append_array(rail_tile_map.get_used_cells_by_id(horizontal))
	rails.append_array(rail_tile_map.get_used_cells_by_id(top_left_corner))
	rails.append_array(rail_tile_map.get_used_cells_by_id(vertical))
	rails.append_array(rail_tile_map.get_used_cells_by_id(bottom_right_corner))
	rails.append_array(rail_tile_map.get_used_cells_by_id(bottom_left_corner))
	
	var current_path = PoolVector2Array()
	current_path.push_back(start_coord)
	var used_coords = PoolVector2Array()
	
	var current_rail_pos = start_coord
	for i in rails.size():
		for coord in rails:
			if coord.distance_to(current_rail_pos) <= 1 and not used_coords.has(coord):
				current_path.push_back(coord)
				used_coords.push_back(coord)
		current_rail_pos = current_path[current_path.size() - 1]
	current_path.push_back(finish_coord)
	
	var result = PoolVector2Array()
	
	for coord in current_path:
		var world_coord = rail_tile_map.map_to_world(coord)
		result.push_back(Vector2(world_coord.x + 16, world_coord.y + 16))
		
	return result
	
func _get_correct_world_coord(coord: Vector2) -> Vector2:
	var world_coord = rail_tile_map.map_to_world(coord)
	return (Vector2(world_coord.x + 16, world_coord.y + 16))
	
func _get_lowest_rail_coord() -> Vector2:
	var rails = rail_tile_map.get_used_cells_by_id(0)
	var lowest = rails[0]
	for rail in rails:
		if rail.y > lowest.y:
			lowest = rail
	return lowest
	
func calculateVolume(distance: float) -> float:
	var maxVolume = 0.5
	var maxDistance = 400
	var volume = maxVolume / (distance * distance)
	
	volume = clamp(volume, 0.0, maxVolume)
	
	if distance > maxDistance:
		volume = 0.0
	
	return volume

func _process(delta: float) -> void:
	is_train_in_motion = is_paused == false and target_pos != null

	if is_paused:
		return

	if Input.is_action_just_pressed("start_train") and target_pos == null:
		#_start_train()
		pass

	var current_cell_coord = rail_tile_map.world_to_map(global_position)
	if last_cell_coords != current_cell_coord:
		last_cell_coords = current_cell_coord
		tiles_traveled += 1
		score += 1
		
		if tiles_traveled >= stop_after_tiles_traveled:
			_start_resting()
			return

		emit_signal("tile_changed", last_cell_coords, stop_after_tiles_traveled - tiles_traveled)
		
		if is_leading_train and real_tile_map.get_cellv(current_cell_coord) != - 1:
			 _train_crashed("real tile map is not empty")

	if target_pos != null:
		if global_position.distance_to(target_pos) <= 1:
			path.remove(0)
			if path.size() == 0:
				target_pos = null
				if is_leading_train:
					_train_crashed("end of path")
			else:
				target_pos = _get_correct_world_coord(path[0])
		else:
			current_velocity = global_position.direction_to(target_pos)
		var _collisions = move_and_collide(current_velocity * speed * delta)

func _train_crashed(from_where: String) -> void:
	emit_signal("train_finished", score)
	print_debug("train crashed from: ", from_where)
	_turn_off_all_lights(self)
	$Humming.stop()
	$Finish.play()

# Returns null or Vector2
func _find_connected_rail_pos(current_rail_pos: Vector2):
	for rail_pos in rail_cells_coords:
		if abs(rail_pos.x - current_rail_pos.x) == 1 or abs(rail_pos.y - current_rail_pos.y) == 1:
			return rail_pos
	return null

func _on_RailTileMap_path_updated(tile) -> void:
	path.push_back(tile)

func _on_RailTileMap_path_remove_last_tile() -> void:
	path.remove(path.size() - 1)
	
func _turn_off_all_lights(node: Node2D) -> void:
	for child in node.get_children():
		if child is Light2D:
			child.enabled = false
		elif child.get_child_count() > 0:
			_turn_off_all_lights(child)
			
func _on_RestTrainTimer_timeout() -> void:
	is_paused = false
	tiles_traveled = 0
	speed += 5
	emit_signal("train_stop_resting")

func _on_SpeechContainer_game_started() -> void:
	is_paused = false

func _on_SpeechContainer_game_paused() -> void:
	is_paused = true
	
func _on_SpeechContainer_game_resumed() -> void:
	is_paused = false

func _on_Player_rocks_drilled_count_changed(count) -> void:
	if count >= 10 and is_start_of_game:
		#$StartTrainTimer.start()
		is_start_of_game = false

func _on_PlayerDetectionArea_body_entered(body: Node) -> void:
	if body is Player and is_train_in_motion:
		_train_crashed("player entered")

func _on_StartTrainTimer_timeout() -> void:
	_start_train()
