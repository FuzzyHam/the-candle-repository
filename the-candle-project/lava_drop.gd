extends Area2D

var speed = 2
var magma_origin

func _physics_process(delta: float) -> void:
	global_position.y += 10



func _on_body_entered(body: Node2D) -> void:
	if body != magma_origin:
		if body.has_signal("hurt"):
			body.hurt.emit(-1)
		if body.has_signal("crawler_die"):
			body.crawler_die.emit(body)
		queue_free()
