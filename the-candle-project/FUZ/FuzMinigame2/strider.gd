extends Area2D

signal strider_shoot

const START_SPEED = 250.0
var speed = START_SPEED
var frames_traveled = 0.0
var jump_frames = 0
const MAX_BULLETS = 3.0
var bullets_left = MAX_BULLETS
var shoot_offset = 0
var a = 1

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	if int(speed) > 0:
		a = (1.0 / 5) ** (frames_traveled / 60.0)
	else:
		a = 0
	speed = START_SPEED * a
	frames_traveled += 1

	if bullets_left > 0:
		if a < 1 + shoot_offset:
			strider_shoot.emit(self)
			shoot_offset -= 1.0 / MAX_BULLETS
			bullets_left -= 1

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_jump_timer_timeout() -> void:
	speed = START_SPEED
	frames_traveled = 0.0
	jump_frames = 0
	bullets_left = MAX_BULLETS
	shoot_offset = 0
	
