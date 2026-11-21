class_name LocalInput
extends Node

@export var frog: Frog
@export var jump_distance_rate: float = 32


func _physics_process(delta: float) -> void:
	assert(frog != null, "LocalInput needs its frog export set")
	var left := Input.is_action_pressed("turn_left")
	var right := Input.is_action_pressed("turn_right")
	var jump := Input.is_action_pressed("jump")
	if jump:
		frog.jump()
	if left or right and left != right:
		frog.turn(Frog.Direction.LEFT if left else Frog.Direction.RIGHT, delta)

	var distance_axis := Input.get_axis("decrease_jump_distance", "increase_jump_distance")
	frog.jump_distance = maxf(0.0, frog.jump_distance + distance_axis * jump_distance_rate * delta)
