extends CharacterBody2D

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 150.0
var direction = -1

signal crawler_die
signal check_crawler_raycast

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if ray_cast_right.is_colliding():
		check_crawler_raycast.emit(self, ray_cast_right.get_collider())
		direction = -1
		
	if ray_cast_left.is_colliding():
		check_crawler_raycast.emit(self, ray_cast_left.get_collider())
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
	
	


func _on_hurt_box_body_entered(body: Node2D) -> void:
	check_crawler_raycast.emit(self, body)
