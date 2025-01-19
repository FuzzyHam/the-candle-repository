extends Area2D

signal powerup_get

func _on_body_entered(body: Node2D) -> void:
	powerup_get.emit(self)
