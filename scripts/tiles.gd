extends TileMap

class_name Tiles

onready var player = $"../Player"

export(bool) var is_rail = false

export var rail_tile = 4
const ground_tile = -1
const wall_tile = 2
const rock_tile = 3

func is_wall_tile(coords: Vector2) -> bool:
	return get_cellv(coords) == wall_tile

func place_rails(coords: Vector2) -> void:
	set_cellv(coords, rail_tile)
	update_autotile_for_cel(coords)

func place_ground(coords: Vector2) -> void:
	set_cellv(coords, ground_tile)

func update_autotile_for_cel(coords: Vector2) -> void:
	update_bitmask_area(coords)

func _place_finish_tile_at_row(row: int) -> void:
	var finish_row = get_used_cells_by_id(3)[0]
	set_cellv(finish_row, -1)
	set_cell(finish_row.x, row, 3)

func _on_RealTileMap_map_size_increased(max_row) -> void:
	if is_rail:
		_place_finish_tile_at_row(max_row)
