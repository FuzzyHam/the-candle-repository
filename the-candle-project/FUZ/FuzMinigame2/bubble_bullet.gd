extends Area2D

var speed = 150
var bullet_type = "normal"

signal hurt

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta



func _on_body_entered(body: Node2D) -> void:
	hurt.emit(self)
	queue_free()
