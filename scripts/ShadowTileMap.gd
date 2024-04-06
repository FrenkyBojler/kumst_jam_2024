extends TileMap

export(NodePath) var player_node_path
onready var player_node := get_node(player_node_path) as Player

export(NodePath) var rail_tile_map_path
onready var rail_tile_map := get_node(rail_tile_map_path) as TileMap

onready var _last_player_map_pos = Vector2.ZERO

onready var _cells_used_by_rail = rail_tile_map.get_used_cells_by_id(4)

func _process(_delta: float) -> void:
	if _last_player_map_pos == _get_player_map_pos():
		return
	
	_cells_used_by_rail = rail_tile_map.get_used_cells_by_id(4)
	_last_player_map_pos = _get_player_map_pos()
	_add_hard_shadow_to_surounding_cells()
	_add_light_shadow_to_given_cell_coords(_get_second_close_neighbor_cells())
	_add_light_shadow_to_given_cell_coords(_cells_used_by_rail)
	_remove_shadow_from_given_cell_coords(_get_close_neighbor_cells())
	_remove_shadow_from_given_cell_coords([_get_player_map_pos()] as PoolVector2Array)
	
func _get_player_map_pos() -> Vector2:
	return world_to_map(player_node.global_position)

func _add_hard_shadow_to_surounding_cells() -> void:
	var player_map_pos := world_to_map(player_node.global_position)
	var player_pos_x := player_map_pos.x
	var player_pos_y := player_map_pos.y
	
	var rows := 25
	var columns := 25
	
	for i in range(player_pos_x - rows, player_pos_x + rows):
		for y in range(player_pos_y - columns, player_pos_y + columns):
			if _cells_used_by_rail.has(Vector2(i,y)):
				continue
			set_cell(i, y, 1)

func _remove_shadow_from_given_cell_coords(coords: PoolVector2Array) -> void:
	for coord in coords:
		set_cellv(coord, -1)

func _add_light_shadow_to_given_cell_coords(coords: PoolVector2Array) -> void:
	for coord in coords:
		set_cellv(coord, 0)

func _get_close_neighbor_cells() -> PoolVector2Array:
	var player_map_pos := world_to_map(player_node.global_position)
	var player_pos_x := player_map_pos.x
	var player_pos_y := player_map_pos.y
	
	var array = [PoolVector2Array()]

	array.push_back(Vector2(player_pos_x - 1, player_pos_y))
	array.push_back(Vector2(player_pos_x + 1, player_pos_y))
	array.push_back(Vector2(player_pos_x, player_pos_y + 1))
	array.push_back(Vector2(player_pos_x, player_pos_y - 1))
	
	return array
	
func _get_second_close_neighbor_cells() -> PoolVector2Array:
	var player_map_pos := world_to_map(player_node.global_position)
	var player_pos_x := player_map_pos.x
	var player_pos_y := player_map_pos.y
	
	var array = [PoolVector2Array()]

	array.push_back(Vector2(player_pos_x - 2, player_pos_y))
	array.push_back(Vector2(player_pos_x - 1, player_pos_y + 1))
	array.push_back(Vector2(player_pos_x + 2, player_pos_y))
	array.push_back(Vector2(player_pos_x + 1, player_pos_y + 1))
	array.push_back(Vector2(player_pos_x, player_pos_y + 2))
	array.push_back(Vector2(player_pos_x - 1, player_pos_y - 1))
	array.push_back(Vector2(player_pos_x, player_pos_y - 2))
	array.push_back(Vector2(player_pos_x + 1, player_pos_y - 1))
	
	return array
