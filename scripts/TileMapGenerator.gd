extends Tiles

class_name TileMapGenerator

onready var player_last_y_pos: int
onready var player_max_y_pos: int
onready var max_y_pos = _get_max_y_pos_from_used_cells()

const generator_ground_id = 5
const generator_wall_id = 2
const generator_rock_id = 6
const generator_left_barrier_id = 1
const generator_right_barrier_id = 3

const max_generated_value = 20
var random_tile_id_generator = RandomNumberGenerator.new()

export(bool) var generate_only_ground = false

const tiles_row = [generator_left_barrier_id, generator_wall_id, generator_rock_id, generator_rock_id, generator_wall_id, generator_right_barrier_id]

func _ready() -> void:
	player_last_y_pos = world_to_map(player.global_position).y
	player_max_y_pos = player_last_y_pos

func _process(_delta: float) -> void:
	var player_current_y_pos = world_to_map(player.global_position).y
	if player_current_y_pos != player_last_y_pos:
		if  player_max_y_pos > player_current_y_pos:
			_place_new_tile_at_row(max_y_pos)
			player_last_y_pos = player_current_y_pos
			player_max_y_pos = player_current_y_pos
			max_y_pos -= 1

func _place_new_tile_at_row(row: int) -> void:
	var start_index_x := -4
	var index = 0
	var generated_tiles = _generate_line(tiles_row.size() - 2)
	generated_tiles.shuffle()
	generated_tiles.push_front(generator_left_barrier_id)
	generated_tiles.push_front(generator_wall_id)
	generated_tiles.push_back(generator_right_barrier_id)
	generated_tiles.push_back(generator_wall_id)
	
	for tile in generated_tiles:
		if generate_only_ground:
			set_cell(start_index_x, row, generator_ground_id)
		else:
			set_cell(start_index_x, row, generated_tiles[index])
		start_index_x += 1
		index += 1

func _generate_line(size: int) -> Array:
	var result = Array()
	var current_generated_value = 0
	
	for i in size:
		var currently_generated_value: int = 0
		random_tile_id_generator.randomize()
		var random = random_tile_id_generator.randi_range(0, 1)
		if random == 1:
			currently_generated_value = generator_wall_id
		else:
			currently_generated_value = generator_rock_id
		if current_generated_value + current_generated_value >= max_generated_value:
			currently_generated_value = generator_wall_id
		result.push_back(currently_generated_value)
		current_generated_value += currently_generated_value
	return result

func _get_max_y_pos_from_used_cells() -> int:
	var max_y_pos: int
	for pos in get_used_cells():
		if max_y_pos == null or max_y_pos > pos.y:
			max_y_pos = pos.y
	return max_y_pos
