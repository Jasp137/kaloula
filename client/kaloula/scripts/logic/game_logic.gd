class_name GameLogic
extends Node
## The match rules: paint budgets, paint pools, stomps and the round timer.

## Emitted when the time runs out. `winners`: the player ids with the most tiles in
## their team colour; `losers`: everyone else (empty on a tie).
signal round_over(winners: Array[int], losers: Array[int])

@export var map: Map
@export var frogs: Dictionary[int, Frog] = {}
@export var paint_budget: int = 10000
## Each player's paint pool cell; the pool takes that frog's starting colour.
@export var pool_cells: Dictionary[int, Vector2i] = {}
@export var pool_scene: PackedScene
## Length of a round in seconds; at 0 the round ends and the losers flip onto
## their backs. 0 or less = no time limit.
@export var round_seconds: float = 90.0

## Seconds left in the round.
var time_left: float = 0.0
var _round_over := false

var _paint_budgets: Dictionary[int, int] = {}
var _pool_cells: Dictionary[Vector2i, PaintPool] = {}
var _player_colors: Dictionary[int, Color] = {}


func _ready() -> void:
	time_left = round_seconds
	assert(map != null, "GameLogic needs its map export set")
	assert(not frogs.is_empty(), "GameLogic needs at least one frog in its frogs export")
	assert(pool_scene != null, "GameLogic needs its pool_scene export set")
	assert(pool_cells.keys() == frogs.keys(), "GameLogic needs one pool cell per player id (frogs %s, pool_cells %s)" % [frogs.keys(), pool_cells.keys()])
	for player_id in frogs:
		var frog := frogs[player_id]
		assert(frog != null, "GameLogic's frogs export has no frog for player %d" % player_id)
		_set_paint(player_id, paint_budget)
		frog.jumped.connect(_on_frog_jumped.bind(player_id))
		_place_pool(player_id, pool_cells[player_id], frog.color)
		_player_colors[player_id] = frog.color


func _place_pool(player_id: int, cell: Vector2i, color: Color) -> void:
	assert(map.get_cell_source_id(cell) != -1, "player %d's pool cell %s is not on a tile" % [player_id, cell])
	assert(cell not in _pool_cells, "player %d's pool cell %s is taken by another pool" % [player_id, cell])
	
	# Spawn the pool
	var pool: PaintPool = pool_scene.instantiate()
	pool.name = "PaintPool%d" % player_id
	pool.color = color
	var world := map.get_parent()
	world.add_child(pool)
	# Make visible
	world.move_child(pool, map.get_index() + 1)
	pool.global_position = map.to_global(map.map_to_local(cell))
	_pool_cells[cell] = pool

func _on_frog_jumped(cell: Vector2i, player_id: int) -> void:
	for other_id in get_players_on(cell):
		if other_id != player_id:
			frogs[other_id].color = frogs[player_id].color
			_set_paint(other_id, 10_000)
	var pool: PaintPool = _pool_cells.get(cell)
	if pool != null:
		_set_paint(player_id, paint_budget)
		frogs[player_id].color = pool.color
		return
	if _paint_budgets[player_id] > 0 and map.paint_cell(cell, frogs[player_id].color):
		_set_paint(player_id, _paint_budgets[player_id] - 1)


## Every paint budget change goes through here so the frog knows how much paint
## it has (it turns back to its base green at 0).
func _set_paint(player_id: int, amount: int) -> void:
	_paint_budgets[player_id] = amount
	frogs[player_id].paint_left = amount


func get_paint_left(player_id: int) -> int:
	return _paint_budgets.get(player_id, 0)


func _process(delta: float) -> void:
	if round_seconds <= 0.0 or _round_over:
		return
	time_left = maxf(0.0, time_left - delta)
	if time_left == 0.0:
		_end_round()


## Tiles currently in the player's team colour.
func get_tiles(player_id: int) -> int:
	return map.count_cells_with_color(_player_colors[player_id])


func is_round_over() -> bool:
	return _round_over


func _end_round() -> void:
	_round_over = true
	var best := -1
	for player_id in frogs:
		best = maxi(best, get_tiles(player_id))
	var winners: Array[int] = []
	var losers: Array[int] = []
	for player_id in frogs:
		if get_tiles(player_id) == best:
			winners.append(player_id)
		else:
			losers.append(player_id)
	for player_id in frogs:
		frogs[player_id].can_move = false
	for player_id in losers:
		frogs[player_id].lose()
	round_over.emit(winners, losers)


func get_players_on(cell: Vector2i) -> Array[int]:
	var ids: Array[int] = []
	for player_id in frogs:
		if map.local_to_map(map.to_local(frogs[player_id].global_position)) == cell:
			ids.append(player_id)
	return ids
