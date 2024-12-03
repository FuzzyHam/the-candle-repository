extends Area2D

var speed = 250

signal hurt

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta



func _on_body_entered(body: Node2D) -> void:
	hurt.emit()
	queue_free()
