@tool
class_name PaintPool
extends Node2D

## Game overwrites this with the owning frog's starting colour.
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, color)
	draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, color.darkened(0.4), 2.0)
