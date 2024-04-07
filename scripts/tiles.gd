extends TileMap

class_name Tiles

onready var player = $"../Player"

export(bool) var is_rail = false
export(bool) var is_rail_placing_tile_set = false

export(NodePath) var actual_rail_tile_map_path
onready var actual_rail_tile_map = get_node(actual_rail_tile_map_path) as Tiles

export var rail_tile = 4
const ground_tile = -1
const wall_tile = 2
const rock_tile = 3

var last_placed_rail = null
var last_last_placed_rail = null

var path := PoolVector2Array()

func _ready() -> void:
	if is_rail:
		last_placed_rail = _find_start_rail()

func _find_start_rail() -> Vector2:
	return actual_rail_tile_map.get_used_cells_by_id(6)[0]

func is_wall_tile(coords: Vector2) -> bool:
	return get_cellv(coords) == wall_tile
	
func place_ghost_rail(coords: Vector2) -> void:
	if coords.distance_to(actual_rail_tile_map.last_placed_rail) > 1 or get_cellv(coords) != -1:
		return
	set_cellv(coords, rail_tile)

func place_rails(coords: Vector2) -> void:
	if coords.distance_to(last_placed_rail) > 1 or get_cellv(coords) != -1:
		return
	path.push_back(coords)
	set_cellv(coords, _get_rail_to_place(coords, last_placed_rail))
	if last_last_placed_rail != null:
		set_cellv(last_placed_rail, _get_rail_to_place_between(last_placed_rail, last_last_placed_rail, coords))
	last_last_placed_rail = last_placed_rail
	last_placed_rail = coords

func place_ground(coords: Vector2) -> void:
	set_cellv(coords, ground_tile)

func update_autotile_for_cel(coords: Vector2) -> void:
	update_bitmask_area(coords)

func _place_finish_tile_at_row(row: int) -> void:
	var finish_row = get_used_cells_by_id(3)[0]
	set_cellv(finish_row, -1)
	set_cell(finish_row.x, row, 3)

func _on_RealTileMap_map_size_increased(max_row) -> void:
	if is_rail_placing_tile_set:
		#_place_finish_tile_at_row(max_row)
		pass
const top_right_corner := 0
const horizontal := 1
const top_left_corner := 2
const vertical := 3
const bottom_right_corner := 4
const bottom_left_corner := 5

func _get_rail_to_place(coords: Vector2, prev_tile_coords: Vector2) -> int:
	if _is_on_left(coords, prev_tile_coords):
		return horizontal
	if _is_on_right(coords, prev_tile_coords):
		return horizontal
	if _is_on_top_(coords, prev_tile_coords):
		return vertical
	if _is_on_bottom(coords, prev_tile_coords):
		return vertical
	else:
		return horizontal

func _get_rail_to_place_between(coords: Vector2, prev_tile_coords: Vector2, next_tile_coords: Vector2) -> int:
	if _is_on_left(coords, prev_tile_coords) and _is_on_top_(coords, next_tile_coords):
		#print("bottom_left_corner")
		return bottom_left_corner
	if _is_on_right(coords, prev_tile_coords) and _is_on_top_(coords, next_tile_coords):
		#print("bottom_right_corner")
		return bottom_right_corner
	if _is_on_left(coords, prev_tile_coords) and _is_on_bottom(coords, next_tile_coords):
		#print("top_left_corner")
		return top_left_corner
	if _is_on_right(coords, prev_tile_coords) and _is_on_bottom(coords, next_tile_coords):
		#print("top_right_corner")
		return top_right_corner
	if _is_on_top_(coords, prev_tile_coords) and _is_on_left(coords, next_tile_coords):
		#print("bottom_left_corner")
		return bottom_left_corner
	if _is_on_top_(coords, prev_tile_coords) and _is_on_right(coords, next_tile_coords):
		#print("bottom_right_corner")
		return bottom_right_corner
	if _is_on_bottom(coords, prev_tile_coords) and _is_on_left(coords, next_tile_coords):
		#print("top_left_corner")
		return top_left_corner
	if _is_on_bottom(coords, prev_tile_coords) and _is_on_right(coords, next_tile_coords):
		#print("top_right_corner")
		return top_right_corner
	if _is_on_bottom(coords, prev_tile_coords) and _is_on_top_(coords, next_tile_coords):
		#print("vertical")
		return vertical
	if _is_on_top_(coords, prev_tile_coords) and _is_on_bottom(coords, next_tile_coords):
		#print("vertical")
		return vertical
	else:
		return horizontal

func _is_on_left(coords: Vector2, target_coords: Vector2) -> bool:
	return coords.x - target_coords.x == 1

func _is_on_right(coords: Vector2, target_coords: Vector2) -> bool:
	return target_coords.x - coords.x == 1

func _is_on_top_(coords: Vector2, target_coords: Vector2) -> bool:
	return coords.y - target_coords.y == 1

func _is_on_bottom(coords: Vector2, target_coords: Vector2) -> bool:
	return target_coords.y - coords.y == 1
