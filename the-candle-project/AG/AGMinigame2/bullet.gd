extends CharacterBody2D

const BULLET_PARTICLE = preload("res://AG/AGMinigame2/bullet_particle.tscn")
const SPEED = 300
@onready var particle_marker: Marker2D = $ParticleMarker
@onready var laser_se: AudioStreamPlayer = $laser_se

func _ready() -> void:
	velocity = Vector2(0, -1).rotated(rotation) * SPEED
	laser_se.pitch_scale=randf_range(0.8,1.05)

func _process(delta: float) -> void:
	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()


func _on_timer_2_timeout() -> void:
	var instance = BULLET_PARTICLE.instantiate()
	instance.global_position = particle_marker.global_position
	get_parent().add_child(instance)
