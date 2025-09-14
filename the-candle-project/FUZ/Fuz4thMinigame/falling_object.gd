extends Area2D

var speed
var direction
var type
var rebound = false

signal object_sig

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
