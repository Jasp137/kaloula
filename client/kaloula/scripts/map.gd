extends TileMapLayer
class_name Map

var _paint: Dictionary[Vector2i, Color] = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func paint_cell(cell: Vector2i, color: Color) -> void:
	assert(get_cell_source_id(cell) != -1, "cannot paint empty cell %s" % cell)
	_paint[cell] = color
	notify_runtime_tile_data_update()


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return coords in _paint


func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate = _paint[coords]
