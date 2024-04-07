extends Node2D

onready var train := get_parent() as Train

onready var sprite_vertical_top = $SpriteVerticalTop
onready var sprite_vertical_bottom = $SpriteVerticalBottom
onready var sprite_horizontal_right = $SpriteHorizontalRight
onready var sprite_horizontal_left = $SpriteHorizontalLeft
onready var sprite_corner_top_left = $SpriteCornerTopLeft
onready var sprite_corner_top_right = $SpriteCornerTopRight
onready var sprite_corner_bottom_left = $SpriteCornerBottomLeft
onready var sprite_corner_bottom_right = $SpriteCornerBottomRight


const top_right_corner := 0
const horizontal := 1
const top_left_corner := 2
const vertical := 3
const bottom_right_corner := 4
const bottom_left_corner := 5

export(bool) var print_velocity = false

func _ready() -> void:
	_turn_vertical_top()
	
func _turn_off_all() -> void:
	sprite_vertical_top.visible = false
	sprite_vertical_bottom.visible = false
	sprite_horizontal_right.visible = false
	sprite_horizontal_left.visible = false
	sprite_corner_top_left.visible = false
	sprite_corner_top_right.visible = false
	sprite_corner_bottom_left.visible = false
	sprite_corner_bottom_right.visible = false

func _turn_vertical_top() -> void:
	_turn_off_all()
	sprite_vertical_top.visible = true
	
func _turn_vertical_bottom() -> void:
	_turn_off_all()
	sprite_vertical_bottom.visible = true

func _turn_horizontal_right() -> void:
	_turn_off_all()
	sprite_horizontal_right.visible = true
	
func _turn_horizontal_left() -> void:
	_turn_off_all()
	sprite_horizontal_left.visible = true
	
func _turn_corner_top_right() -> void:
	_turn_off_all()
	sprite_corner_top_right.visible = true

func _turn_corner_top_left() -> void:
	_turn_off_all()
	sprite_corner_top_left.visible = true
	
func _turn_corner_bottom_left() -> void:
	_turn_off_all()
	sprite_corner_bottom_left.visible = true
	
func _turn_corner_bottom_right() -> void:
	_turn_off_all()
	sprite_corner_bottom_right.visible = true
	
var prev_velocity_y: int = 0

const tolerance = 0.005

func _on_Train_tile_changed(tile) -> void:
	var auto_tile_coord = train.rail_tile_map.get_cell(tile.x, tile.y)
	var vel = train.current_velocity

	match(auto_tile_coord):
		top_right_corner:
			if vel.y > 0:
				_turn_corner_bottom_left()
			else:
				_turn_corner_top_right()
		top_left_corner:
			if vel.y > 0:
				_turn_corner_bottom_right()
			else:
				_turn_corner_top_left()
		bottom_right_corner:
			if vel.y > 0:
				_turn_corner_bottom_right()
			else:
				_turn_corner_top_left()
		bottom_left_corner:
			if vel.y > 0:
				_turn_corner_bottom_left()
			else:
				_turn_corner_top_right()
		horizontal:
			if vel.x < 0:
				_turn_horizontal_left()
			else:
				_turn_horizontal_right()
		vertical:
			if vel.y > 0:
				_turn_vertical_bottom()
			else:
				_turn_vertical_top()
