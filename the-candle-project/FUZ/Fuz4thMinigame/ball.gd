extends Area2D

var speed
var direction
var weight_value = 1.0
var food_type

signal ball_sig

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
