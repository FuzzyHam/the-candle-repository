extends CharacterBody2D

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 250.0
var direction = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if ray_cast_right.is_colliding():
		direction = -1
		
	if ray_cast_left.is_colliding():
		direction = 1
	
	if direction == -1:
		animated_sprite.flip_h = true
	if direction == 1:
		animated_sprite.flip_h = false
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_life_span_timeout() -> void:
	queue_free()
