class_name Game
extends Node2D

@export var frogs: Dictionary[int, Frog] = {}
@export var paint_budget: int = 3
@export var pools: Dictionary[int, PaintPool] = {}
## Paint budget a frog gets when another frog lands on it.
@export var stomped_paint_budget: int = 100000

@onready var map: Map = $World/TileMapLayer

var _paint_budgets: Dictionary[int, int] = {}
var _pool_cells: Dictionary[Vector2i, PaintPool] = {}
var _player_colors: Dictionary[int, Color] = {}


func _ready() -> void:
	assert(not frogs.is_empty(), "Game needs at least one frog in its frogs export")
	assert(pools.keys() == frogs.keys(), "Game needs one pool per player id (frogs %s, pools %s)" % [frogs.keys(), pools.keys()])
	for player_id in frogs:
		var frog := frogs[player_id]
		assert(frog != null, "Game's frogs export has no frog for player %d" % player_id)
		_paint_budgets[player_id] = paint_budget
		frog.jumped.connect(_on_frog_jumped.bind(player_id))
		_place_pool(pools[player_id], frog.color)
		_player_colors[player_id] = frog.color


func _place_pool(pool: PaintPool, color: Color) -> void:
	assert(pool != null, "Game's pools export has an empty slot")
	var cell := map.local_to_map(map.to_local(pool.global_position))
	assert(map.get_cell_source_id(cell) != -1, "%s is not on a tile" % pool.name)
	assert(cell not in _pool_cells, "%s shares cell %s with another pool" % [pool.name, cell])
	pool.global_position = map.to_global(map.map_to_local(cell))
	pool.color = color
	_pool_cells[cell] = pool

func _on_frog_jumped(cell: Vector2i, player_id: int) -> void:
	for other_id in get_players_on(cell):
		if other_id != player_id:
			frogs[other_id].color = frogs[player_id].color
			_paint_budgets[other_id] = stomped_paint_budget
	var pool: PaintPool = _pool_cells.get(cell)
	if pool != null:
		_paint_budgets[player_id] = paint_budget
		frogs[player_id].color = pool.color
		return
	if _paint_budgets[player_id] > 0 and map.paint_cell(cell, frogs[player_id].color):
		_paint_budgets[player_id] -= 1


func get_players_on(cell: Vector2i) -> Array[int]:
	var ids: Array[int] = []
	for player_id in frogs:
		if map.local_to_map(map.to_local(frogs[player_id].global_position)) == cell:
			ids.append(player_id)
	return ids
