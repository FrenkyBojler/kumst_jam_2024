extends Tiles

class_name TileMapGenerator

onready var player_last_y_pos: int
onready var player_max_y_pos: int
onready var max_y_pos = _get_max_y_pos_from_used_cells()

export(NodePath) var ground_tile_map_path
onready var ground_tile_map = get_node(ground_tile_map_path)

const generator_ground_id = 5
const generator_wall_id = 2
const generator_rock_id = 6
const generator_left_barrier_id = 1
const generator_right_barrier_id = 3
const generator_side = 9
const generator_hole = 13

const max_generated_value = 20
var random_tile_id_generator = RandomNumberGenerator.new()

var path_of_walls: PoolVector2Array

export(bool) var generate_only_ground = false
const tiles_row = [generator_left_barrier_id, generator_wall_id, generator_rock_id, generator_rock_id, generator_wall_id, generator_right_barrier_id]

signal map_size_increased(max_row)

func _ready() -> void:
	random_tile_id_generator.randomize()
	player_last_y_pos = world_to_map(player.global_position).y
	player_max_y_pos = player_last_y_pos
	path_of_walls = _generate_path(max_y_pos, -2, 1, 500)

func _process(_delta: float) -> void:
	var player_current_y_pos = world_to_map(player.global_position).y
	if player_current_y_pos != player_last_y_pos:
		if  player_max_y_pos > player_current_y_pos:
			_place_new_tile_at_row(max_y_pos)
			player_last_y_pos = player_current_y_pos
			player_max_y_pos = player_current_y_pos
			max_y_pos -= 1
var wall_from_prev_x_indexes := PoolIntArray()

func _place_new_tile_at_row(row: int) -> void:
	emit_signal("map_size_increased", row)
	var start_index_x := -4
	var index = 0
	var generated_tiles = _generate_line(tiles_row.size() - 2)
	generated_tiles.shuffle()
	
	var path_row
	if not generate_only_ground:
		path_row = _get_path_at_row(row)

	generated_tiles.push_front(generator_left_barrier_id)
	generated_tiles.push_front(generator_side)
	generated_tiles.push_back(generator_right_barrier_id)
	generated_tiles.push_back(generator_side)
	
	if not generate_only_ground:
		if path_row.size() != 0:
			generated_tiles = _fix_row_by_path(generated_tiles, path_row)
	for tile in generated_tiles:
		if not generate_only_ground:
			_place_ground_or_hole(start_index_x, row)
			if wall_from_prev_x_indexes.has(start_index_x - 4) and not _get_real_x_indexes_from_path(path_row).has(start_index_x):
				set_cell(start_index_x, row, generator_rock_id)
			else:
				set_cell(start_index_x, row, generated_tiles[index])
		start_index_x += 1
		index += 1
		
	wall_from_prev_x_indexes = _get_wall_x_indexes_from_row(generated_tiles)
func _get_wall_x_indexes_from_row(row: PoolIntArray) -> PoolIntArray:
	var result := PoolIntArray()
	var index := 0
	for r in row:
		if r == generator_wall_id and index >= 2 and index <= 5:
			result.push_back(index)
		index += 1
	return result

func _get_real_x_indexes_from_path(path: PoolVector2Array) -> PoolIntArray:
	var result = PoolIntArray()
	for p in path:
		result.push_back(4 - p.x)
	return result

func _place_ground_or_hole(x: int, y: int) -> void:
		ground_tile_map.set_cell(x, y, generator_ground_id)

func _get_holes_indexes(row: PoolIntArray, row_path: PoolVector2Array) -> PoolIntArray:
	var result = PoolIntArray()
	var index = -1
	for r in row:
		var can_add = true
		index += 1
		if r != generator_wall_id:
			continue
		for path in row_path:
			var path_index = 4 + path.x
			if index == path_index:
				can_add = false
				break
		if can_add:
			result.push_back(index)
	return result

func _fix_row_by_path(row: PoolIntArray, row_path: PoolVector2Array) -> PoolIntArray:
	var result = row
	for r in row_path:
		var path_index = abs(-4) + r.x
		result[path_index] = generator_wall_id
		
	return result

func _get_path_at_row(row_index: int) -> PoolVector2Array:
	var result = PoolVector2Array()
	for row in path_of_walls:
		if row.y == row_index:
			result.push_back(row)
	return result

func _generate_line(size: int) -> Array:
	var result = Array()
	var current_generated_value = 0
	var wall_count = 0
	for i in size:
		var currently_generated_value: int = 0
		random_tile_id_generator.randomize()
		var random = random_tile_id_generator.randi_range(0, 1)
		if random == 1 and wall_count < 2:
			currently_generated_value = generator_wall_id
			wall_count += 1
		else:
			currently_generated_value = generator_rock_id
		result.push_back(currently_generated_value)
	return result

func _get_passable_wall_positions(current_row: int) -> PoolIntArray:
	var result = PoolIntArray()
	var all_walls = get_used_cells_by_id(generator_wall_id)
	var walls_at_prev_row = _get_walls_coords_from_row(current_row + 1, all_walls)
	for wall in walls_at_prev_row:
		result.push_back(wall.x)

	return result

func _get_walls_coords_from_row(row: int, walls: PoolVector2Array) -> PoolVector2Array:
	var result = PoolVector2Array()
	for wall in walls:
		if wall.y == row:
			result.push_back(wall)
	return result

func _get_max_y_pos_from_used_cells() -> int:
	var max_y_pos: int
	for pos in get_used_cells():
		if max_y_pos == null or max_y_pos > pos.y:
			max_y_pos = pos.y
	return max_y_pos

var random_walls_on_same_row_generator = RandomNumberGenerator.new()
var random_walls_index_on_row_generator = RandomNumberGenerator.new()
var random_direction_on_same_row_generator = RandomNumberGenerator.new()
const max_walls_on_same_row = 2

func _generate_path(start_row: int, first_column: int, last_column: int, rows: int) -> PoolVector2Array:
	var result = PoolVector2Array()
	
	var prev_dir := 0
	for i in rows:
		if result.size() != 0:
			var last_wall_x_index = _get_last_wall_index(result, start_row - (i - 1), prev_dir)
			var random_dir = _get_random_dir()
			var random_walls_on_same_row = _get_random_walls_on_same_row(first_column, last_column, last_wall_x_index, random_dir)
			var index = last_wall_x_index
			for col in random_walls_on_same_row + 1:
				if random_dir == -1:
					result.push_back(Vector2(max(-2, index),  (start_row - i)))
				elif random_dir == 1:
					result.push_back(Vector2(min(1, index),  (start_row - i)))
				else:
					result.push_back(Vector2(index,   (start_row - i)))
				index += random_dir
			prev_dir = random_dir
		else:
			result.push_back(Vector2(first_column, start_row))
	return result

func _get_random_walls_on_same_row(first_column: int, last_column: int, start_index: int, dir: int) -> int:
	random_walls_on_same_row_generator.randomize()
	if dir == -1:
		return  int(max(1, random_walls_on_same_row_generator.randi_range(2, abs(first_column) - abs(start_index))))
	elif dir == 1:
		return int(max(1, random_walls_on_same_row_generator.randi_range(2, abs(last_column) - abs(start_index))))
	else:
		return 1
	
func _get_random_dir() -> int:
	random_direction_on_same_row_generator.randomize()
	var random_dir_index = random_direction_on_same_row_generator.randi_range(0, 2)
	if random_dir_index == 0:
		return  0
	elif random_dir_index == 1:
		return 1
	else:
		return -1

func _get_last_wall_index(walls: PoolVector2Array, index: int, last_dir: int) -> int:
	var walls_on_index = PoolVector2Array()

	for wall in walls:
		if wall.y == index:
			walls_on_index.push_back(wall)

	var last_wall = walls_on_index[0]
	for wall in walls_on_index:
		if last_dir == -1:
			if wall.x < last_wall.x:
				last_wall = wall
		elif last_dir == 1:
			if wall.x > last_wall.x:
				last_wall = wall

	return last_wall.x
