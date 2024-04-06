extends Node2D

onready var train := get_parent() as Train

onready var sprite_vertical = $SpriteVertical
onready var sprite_horizontal = $SpriteHorizontal
onready var sprite_corner_top_left = $SpriteCornerTopLeft
onready var sprite_corner_top_right = $SpriteCornerTopRight

const right_top_corner = Vector2(0, 0)
const left_top_corner = Vector2(2, 0)
const left_bottom_corner = Vector2(2, 2)
const right_bottom_corner = Vector2(0, 2)
const horizontal_1 = Vector2(1, 0)
const horizontal_2 = Vector2(1, 2)
const vertical_1 = Vector2(0, 1)
const vertical_2 = Vector2(2, 1)

func _ready() -> void:
	_turn_vertical()

func _turn_vertical() -> void:
	sprite_vertical.visible = true
	sprite_horizontal.visible = false
	sprite_corner_top_left.visible = false
	sprite_corner_top_right.visible = false

func _turn_horizontal(flip_h: bool) -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = true
	sprite_corner_top_left.visible = false
	sprite_corner_top_right.visible = false
	sprite_horizontal.flip_h = flip_h
	
func _turn_corner_top_right() -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = false
	sprite_corner_top_left.visible = false
	sprite_corner_top_right.visible = true

func _turn_corner_top_left() -> void:
	sprite_vertical.visible = false
	sprite_horizontal.visible = false
	sprite_corner_top_left.visible = true
	sprite_corner_top_right.visible = false

func _turn_corner_bottom_right() -> void:
	_turn_corner_top_left()
	
func _turn_corner_bottome_left() -> void:
	_turn_corner_top_right()

func _on_Train_tile_changed(tile) -> void:
	var auto_tile_coord = train.rail_tile_map.get_cell_autotile_coord(tile.x, tile.y)
	
	match(auto_tile_coord):
		right_top_corner:
			_turn_corner_top_right()
		left_top_corner:
			_turn_corner_top_left()
		right_bottom_corner:
			_turn_corner_bottom_right()
		left_bottom_corner:
			_turn_corner_bottome_left()
		horizontal_1, horizontal_2:
			if train.current_velocity.x < 0:
				_turn_horizontal(true)
			else:
				_turn_horizontal(false)
		vertical_1, vertical_2:
			_turn_vertical()
