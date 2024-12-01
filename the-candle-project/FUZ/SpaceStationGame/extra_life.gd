extends Area2D

signal add_life

func _on_body_entered(body: Node2D) -> void:
	add_life.emit(2)
	queue_free()
