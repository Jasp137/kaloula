class_name LocalInput
extends Node

@export var frog: Frog


func _physics_process(delta: float) -> void:
	assert(frog != null, "LocalInput needs its frog export set")
	var left := Input.is_action_pressed("turn_left")
	var right := Input.is_action_pressed("turn_right")
	if left == right:
		return
	frog.turn(Frog.Direction.LEFT if left else Frog.Direction.RIGHT, delta)
