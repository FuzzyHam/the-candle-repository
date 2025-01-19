extends Area2D

var speed = 500
var range = 200.0
var distance_traveled = 0

signal ore_gain
signal delete_block
signal nitro_explode

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	var prev_position = position
	position += direction * speed * delta
	distance_traveled += sqrt(pow(abs(position.x - prev_position.x), 2) + pow(abs(position.y - prev_position.y), 2))
	if distance_traveled >= range:
		queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body.block_type != "MAGMA":
		if body.block_type == "ORE":
			ore_gain.emit(body)
		if body.block_type == "NITRO":
			print("EXPLODE")
			nitro_explode.emit(body)
		delete_block.emit(body)
	queue_free()
