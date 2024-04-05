extends TileMap

class_name Tiles

const rail_tile = 0
const ground_tile = 3
const wall_tile = 4

func is_wall_tile(coords: Vector2) -> bool:
	return get_cellv(coords) == wall_tile

func place_rails(coords: Vector2) -> void:
	set_cellv(coords, rail_tile)
	update_autotile_for_cel(coords)

func place_ground(coords: Vector2) -> void:
	set_cellv(coords, ground_tile)

func update_autotile_for_cel(coords: Vector2) -> void:
	update_bitmask_area(coords)