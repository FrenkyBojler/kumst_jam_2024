extends Line2D

onready var rail_tile_map = $"../RailTileMap"

const top_right_corner := 0
const horizontal := 1
const top_left_corner := 2
const vertical := 3
const bottom_right_corner := 4
const bottom_left_corner := 5

func _init_vole() -> void:
	var path = rail_tile_map.path
	var used_coords = PoolVector2Array()
	var index := 0
	for coord in path:
		var world_coord = rail_tile_map.map_to_world(coord)
		add_point(Vector2(world_coord.x + 16, world_coord.y + 16), index)
		index += 1
		
func _get_lowest_rail_coord() -> Vector2:
	var rails = rail_tile_map.get_used_cells_by_id(6)
	var lowest = rails[0]
	for rail in rails:
		if rail.y > lowest.y:
			lowest = rail
	return lowest

func _on_RailTileMap_path_updated(tile) -> void:
	clear_points()
	_init_vole()

func _on_RailTileMap_path_remove_last_tile() -> void:
	remove_point(points.size() - 1)
