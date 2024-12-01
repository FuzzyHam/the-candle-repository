extends StaticBody2D

@onready var collide_raycast: RayCast2D = $CollideRaycast
@onready var hurt_raycast: RayCast2D = $HurtRaycast
@onready var beam_life_span: Timer = $BeamLifeSpan
@onready var beam: Line2D = $Beam
@onready var reload: Timer = $Reload
@onready var laser_spawner: AnimatedSprite2D = $LaserSpawner


signal laser_hit
signal laser_fire

func _ready() -> void:
	laser_spawner.play("idle")
	beam.remove_point(1)
	pass
	
func _physics_process(delta: float) -> void:
	if hurt_raycast.is_colliding():
		laser_hit.emit()
		hurt_raycast.enabled = false
		beam.remove_point(1)
	if reload.time_left < 2 && !reload.is_stopped():
		laser_spawner.play("fire")
	else:
		laser_spawner.play("idle")

func _on_reload_timeout() -> void:
	if round(rotation_degrees) == 0 || round(rotation_degrees) == 180:
		hurt_raycast.target_position = Vector2(abs(collide_raycast.get_collision_point().x - hurt_raycast.global_position.x), 0)
	if round(rotation_degrees) == 90 || round(rotation_degrees) == 270:
		hurt_raycast.target_position = Vector2(abs(collide_raycast.get_collision_point().y - hurt_raycast.global_position.y), 0)
	hurt_raycast.enabled = true
	beam_life_span.start()
	if beam.points.size() < 2:
		beam.add_point(hurt_raycast.target_position)
	laser_spawner.play("idle")
	laser_fire.emit()


func _on_beam_life_span_timeout() -> void:
	hurt_raycast.enabled = false
	if beam.points.size() > 1:
		beam.remove_point(1)
