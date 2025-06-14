extends Area2D

var speed
var direction
var type

signal object_sig

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
