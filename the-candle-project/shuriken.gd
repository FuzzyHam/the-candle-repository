extends Area2D

var speed = 500
var type = "shuriken"
var boss = false

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
