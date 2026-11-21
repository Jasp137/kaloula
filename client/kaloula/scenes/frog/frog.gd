extends CharacterBody2D
class_name Frog

@export var jump_distance: float = 40;
@export var color: Color = Color.BLUE
@export var player_id: String = "Player 1"
@export var rotation_speed: float = 1;
@export var map: Map;
@export var jump_highlight: Node2D

@onready var sprite = $AnimatedSprite2D;

enum Direction {
	LEFT,
	RIGHT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(map != null, "Frog needs its map export set")
	assert(jump_highlight != null, "Frog needs its jump_highlight export set")
	sprite.modulate = color
	jump_highlight.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cell := get_jump_cell()
	jump_highlight.visible = map.get_cell_source_id(cell) != -1
	jump_highlight.global_position = map.to_global(map.map_to_local(cell))


func get_jump_cell() -> Vector2i:
	var target := global_position + Vector2.UP.rotated(global_rotation) * jump_distance
	return map.local_to_map(map.to_local(target))

func jump():
	pass

func turn(direction: Direction, delta: float) -> void:
	var sign := -1.0 if direction == Direction.LEFT else 1.0
	rotate(sign * rotation_speed * delta)
