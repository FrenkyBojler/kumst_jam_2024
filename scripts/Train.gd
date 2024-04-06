extends KinematicBody2D

export(NodePath) var target_pos_node_path
onready var target_pos = get_node(target_pos_node_path) as Position2D

onready var sprite_vertical = $SpriteVertical
onready var sprite_horizontal = $SpriteHorizontal
onready var sprite_corner = $SpriteCorner

onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
var nav_path: PoolVector2Array

var current_velocity: Vector2 = Vector2.ZERO
var speed := 100.0

func _ready() -> void:
	_turn_vertical()
	nav_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, target_pos.global_position, false)
	print(nav_path)

func _process(delta: float) -> void:
	if nav_path.size() > 1:
		var target = nav_path[0]
		current_velocity = global_position.direction_to(target)
		nav_agent.set_velocity(current_velocity * delta * speed)
		
		if global_position.distance_to(target) <= 1:
			nav_path.remove(0)

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
