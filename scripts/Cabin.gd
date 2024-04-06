extends Node2D

onready var train := get_parent() as Train

onready var sprite_vertical = $SpriteVertical
onready var sprite_horizontal = $SpriteHorizontal
onready var sprite_corner_top_left = $SpriteCornerTopLeft
onready var sprite_corner_top_right = $SpriteCornerTopRight

const top_right_corner := 0
const horizontal := 1
const top_left_corner := 2
const vertical := 3
const bottom_right_corner := 4
const bottom_left_corner := 5

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
	var auto_tile_coord = train.rail_tile_map.get_cell(tile.x, tile.y)
	
	match(auto_tile_coord):
		top_right_corner:
			_turn_corner_top_right()
		top_left_corner:
			_turn_corner_top_left()
		bottom_right_corner:
			_turn_corner_bottom_right()
		bottom_left_corner:
			_turn_corner_bottome_left()
		horizontal:
			if train.current_velocity.x < 0:
				_turn_horizontal(true)
			else:
				_turn_horizontal(false)
		vertical:
			_turn_vertical()
