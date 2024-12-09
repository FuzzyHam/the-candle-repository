extends Area2D

var speed = 300
var bubble_type = "normal"
var shot = false

signal hurt
signal explode
signal score_gain
signal lifespan_die


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if bubble_type != "flower":
		speed -= 5
		if speed < 0:
			speed = 0
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	hurt.emit()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	explode.emit(self)
	score_gain.emit(self)
	area.queue_free()
	shot = true
	queue_free()

func _on_life_span_1_timeout() -> void:
	if bubble_type == "normal":
		modulate = Color(0.8, 0.2, 1, 1)
	if bubble_type == "mega":
		modulate = Color(0.6, 0, 0, 1)


func _on_life_span_2_timeout() -> void:
	explode.emit(self)
	lifespan_die.emit()
	queue_free()
