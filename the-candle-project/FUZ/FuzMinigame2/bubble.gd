extends Area2D

var speed = 500

signal hurt
signal explode

func _ready() -> void:
	modulate = Color(1, 1, 1, 1)

func _physics_process(delta: float) -> void:
	speed -= 10
	if speed < 0:
		speed = 0
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	hurt.emit()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	explode.emit(self)
	area.queue_free()
	queue_free()

func _on_life_span_1_timeout() -> void:
	modulate = Color(0.609, 0.338, 0.94, 1)


func _on_life_span_2_timeout() -> void:
	hurt.emit()
	explode.emit(self)
	queue_free()
