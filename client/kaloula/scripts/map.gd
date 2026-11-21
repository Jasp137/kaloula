extends TileMapLayer
class_name Map

var _paint: Dictionary[Vector2i, Color] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func paint_cell(cell: Vector2i, color: Color) -> bool:
	assert(get_cell_source_id(cell) != -1, "cannot paint empty cell %s" % cell)
	var will_change: bool = _paint.get(cell) != color
	_paint[cell] = color
	notify_runtime_tile_data_update()
	return will_change

## Number of tiles currently painted `color`.
func count_cells_with_color(color: Color) -> int:
	var n := 0
	for c in _paint.values():
		if c.is_equal_approx(color):
			n += 1
	return n

func get_cell_color(cell: Vector2i) -> Color:
	return _paint.get(cell)

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return coords in _paint


func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate = _paint[coords]
