class_name ShapeOutline
extends Node2D
## Outline around a set of map cells. Drawn in the map's local space, so add it as a child of the Map.

@export var color: Color = Color(1, 1, 1, 0.9)
@export var width: float = 2.0

var cells: Array[Vector2i] = []:
	set(value):
		cells = value
		queue_redraw()

# Per cell side: the neighbour across it and the side's two corners (in half-tile units).
const _SIDES := [
	[Vector2i.UP, Vector2(-1, -1), Vector2(1, -1)],
	[Vector2i.DOWN, Vector2(-1, 1), Vector2(1, 1)],
	[Vector2i.LEFT, Vector2(-1, -1), Vector2(-1, 1)],
	[Vector2i.RIGHT, Vector2(1, -1), Vector2(1, 1)],
]


func _draw() -> void:
	var map := get_parent() as Map
	assert(map != null, "ShapeOutline must be a child of the Map")
	var half := Vector2(map.tile_set.tile_size) / 2.0
	for cell in cells:
		var center := map.map_to_local(cell)
		for side in _SIDES:
			if cell + side[0] in cells:
				continue
			var a: Vector2 = center + half * side[1]
			var b: Vector2 = center + half * side[2]
			# Extend by half the width so neighbouring edges meet without a notch at the corners.
			var overhang := (b - a).normalized() * width / 2.0
			draw_line(a - overhang, b + overhang, color, width)
