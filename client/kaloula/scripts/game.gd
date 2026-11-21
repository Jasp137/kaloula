class_name Game
extends Node2D

@export var logic: GameLogic
@export var score: Score

func _ready() -> void:
	assert(logic != null, "Game needs its logic export set")
	assert(score != null, "Game needs score component")
