extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -375.0

@onready var up_cast: RayCast2D = $UpCast
@onready var down_cast_right: RayCast2D = $DownCastRight
@onready var down_cast_left: RayCast2D = $DownCastLeft
@onready var gun_pivot: Marker2D = $GunPivot
@onready var gun_ray_cast: RayCast2D = $GunPivot/GunRayCast
@onready var beam: Line2D = $GunPivot/Beam
@onready var cpu_particles: CPUParticles2D = $GunPivot/Target/CPUParticles2D
@onready var target: Marker2D = $GunPivot/Target

signal crush_check
signal shoot
signal hurt

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("shoot"):
		shoot.emit()
		
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if (down_cast_right.is_colliding() || down_cast_left.is_colliding()) && up_cast.is_colliding():
		crush_check.emit()
		
	gun_pivot.look_at(get_global_mouse_position())
		
	move_and_slide()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	hurt.emit(-1)
	
	if body.has_signal("crawler_die"):
		body.crawler_die.emit(body)
