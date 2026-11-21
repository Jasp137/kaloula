class_name GameAudio
extends Node
## Sounds for game events, each played where it happened. Listens to GameLogic; the
## rules never call audio.

@export var logic: GameLogic
@export var paint_sound: AudioStream
@export var stomped_sound: AudioStream

# One player per sound and player id, so two frogs' sounds pan independently.
var _paint_players: Dictionary[int, AudioStreamPlayer2D] = {}
var _stomped_players: Dictionary[int, AudioStreamPlayer2D] = {}


func _ready() -> void:
	assert(logic != null, "GameAudio needs its logic export set")
	assert(paint_sound != null and stomped_sound != null, "GameAudio needs its paint_sound and stomped_sound exports set")
	for player_id in logic.frogs:
		_paint_players[player_id] = _add_player(paint_sound)
		_stomped_players[player_id] = _add_player(stomped_sound)
	logic.cell_painted.connect(_on_cell_painted)
	logic.stomped.connect(_on_stomped)


func _add_player(stream: AudioStream) -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = GameSettings.SFX_BUS
	# The whole board is on screen: pan by position, never fade with distance.
	player.attenuation = 0.0
	player.max_distance = 100000.0
	# A frog can paint again before the 1.3 s splash ends.
	player.max_polyphony = 3
	add_child(player)
	return player


func _on_cell_painted(cell: Vector2i, player_id: int) -> void:
	_play_at(_paint_players[player_id], logic.map.to_global(logic.map.map_to_local(cell)))


func _on_stomped(victim_id: int, _by_id: int) -> void:
	_play_at(_stomped_players[victim_id], logic.frogs[victim_id].global_position)


func _play_at(player: AudioStreamPlayer2D, at: Vector2) -> void:
	player.global_position = at
	player.play()
