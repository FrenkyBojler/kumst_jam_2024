extends Line2D

onready var rail_tile_map = $"../RailTileMap"

func _ready() -> void:
	var index := 0
	var start_coord = _get_lowest_rail_coord()
	var finish_coord = rail_tile_map.get_used_cells_by_id(3)[0]
	var rails = rail_tile_map.get_used_cells_by_id(0)
	rails.remove(rails.find(start_coord))
	var path = PoolVector2Array()
	path.push_back(start_coord)
	var used_coords = PoolVector2Array()
	
	var current_rail_pos = start_coord
	for i in rails.size():
		for coord in rails:
			if coord.distance_to(current_rail_pos) <= 1 and not used_coords.has(coord):
				path.push_back(coord)
				used_coords.push_back(coord)
		current_rail_pos = path[path.size() - 1]
	path.push_back(finish_coord)
	
	for coord in path:
		var world_coord = rail_tile_map.map_to_world(coord)
		add_point(Vector2(world_coord.x + 16, world_coord.y + 16), index)
		index += 1
		
func _get_lowest_rail_coord() -> Vector2:
	var rails = rail_tile_map.get_used_cells_by_id(0)
	var lowest = rails[0]
	for rail in rails:
		if rail.y > lowest.y:
			lowest = rail
	return lowest
