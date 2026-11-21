extends CharacterBody2D
class_name Frog

@export var jump_distance: float = 40;
@export var color: Color = Color.BLUE
@export var player_id: String = "Player 1"
@export var rotation_speed: float = 1;
@export var map: Map;
@export var jump_highlight: Node2D
@export var jump_cooldown: float = 0.5;

@onready var rig: FrogRig = $Rig;

var time_since_last_jump = 0;

enum Direction {
	LEFT,
	RIGHT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(map != null, "Frog needs its map export set")
	assert(jump_highlight != null, "Frog needs its jump_highlight export set")
	rig.palette = FrogPalette.from_color(color)
	jump_highlight.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cell := get_jump_cell_map_coords()
	jump_highlight.visible = map.get_cell_source_id(cell) != -1
	jump_highlight.global_position = map.to_global(map.map_to_local(cell))
	
	time_since_last_jump += delta;


func get_jump_cell_map_coords() -> Vector2i:
	var target := global_position + Vector2.UP.rotated(global_rotation) * jump_distance
	return map.local_to_map(map.to_local(target))

func jump() -> bool:
	if time_since_last_jump < jump_cooldown:
		return false
	
	var target_cell := get_jump_cell_map_coords()
	if map.get_cell_source_id(target_cell):
		return false
		
	var target_coords := map.to_global(map.map_to_local(target_cell))
		
	global_position = target_coords;
	map.paint_cell(target_cell, color)
	
	time_since_last_jump = 0
	
	return true

func turn(direction: Direction, delta: float) -> void:
	var sign := -1.0 if direction == Direction.LEFT else 1.0
	rotate(sign * rotation_speed * delta)
	rig.turn_by(sign * rotation_speed * delta)
