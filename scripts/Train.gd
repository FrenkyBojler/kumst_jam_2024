extends KinematicBody2D

export(NodePath) var rail_tile_map_path
onready var rail_tile_map = get_node(rail_tile_map_path) as TileMap

onready var sprite_vertical = $SpriteVertical
onready var sprite_horizontal = $SpriteHorizontal
onready var sprite_corner = $SpriteCorner

onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
var nav_path: PoolVector2Array

var current_velocity: Vector2 = Vector2.ZERO
var speed := 100.0

var rai_cell_id = 0
var finish_cell_id = 3
var start_cell_id = 2

var start_cell_coord: Vector2
var finish_cell_coord: Vector2
var rail_cells_coords: PoolVector2Array

#Vector2 or Null
var target_pos

var path: PoolVector2Array

func _start_train() -> void:
	_turn_vertical()
	path = _get_path()
	global_position = path[0]
	target_pos = path[0]

func _ready() -> void:
	pass

func _get_path() -> PoolVector2Array:
	var start_coord = rail_tile_map.get_used_cells_by_id(2)[0]
	var finish_coord = rail_tile_map.get_used_cells_by_id(3)[0]
	var rails = rail_tile_map.get_used_cells_by_id(0)
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
	
	var result = PoolVector2Array()
	
	for coord in path:
		var world_coord = rail_tile_map.map_to_world(coord)
		result.push_back(Vector2(world_coord.x + 16, world_coord.y + 16))
		
	return result

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start_train") and target_pos == null:
		_start_train()

	if target_pos != null:
		if global_position.distance_to(target_pos) <= 1:
			path.remove(0)
			if path.size() == 0:
				target_pos = null
			else:
				target_pos = path[0]
		else:
			current_velocity = global_position.direction_to(target_pos)
		move_and_collide(current_velocity * speed * delta)

# Returns null or Vector2
func _find_connected_rail_pos(current_rail_pos: Vector2):
	for rail_pos in rail_cells_coords:
		if abs(rail_pos.x - current_rail_pos.x) == 1 or abs(rail_pos.y - current_rail_pos.y) == 1:
			return rail_pos
	return null

func _turn_vertical() -> void:
	sprite_vertical.visible = true
	sprite_horizontal.visible = false
	sprite_corner.visible = false

func _turn_horizontal() -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = true
	sprite_corner.visible = false
	
func _turn_corner_top_right() -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = false
	sprite_corner.visible = true
	sprite_corner.flip_h = true

func _turn_corner_top_left() -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = false
	sprite_corner.visible = true
	sprite_corner.flip_h = false
	
func _turn_corner_bottom_right() -> void:
	_turn_corner_top_left()
	
func _turn_corner_bottome_left() -> void:
	_turn_corner_top_right()


func _on_NavigationAgent2D_velocity_computed(safe_velocity: Vector2) -> void:
	move_and_collide(safe_velocity)
