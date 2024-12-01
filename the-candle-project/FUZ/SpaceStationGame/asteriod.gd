extends Area2D

var speed
var direction
signal asteriod_hit

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	#queue_free()



func _on_body_entered(body: Node2D) -> void:
	asteriod_hit.emit()
	queue_free()
