extends Area2D

var speed
var direction
var weight_value = 1

signal ball_sig

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
