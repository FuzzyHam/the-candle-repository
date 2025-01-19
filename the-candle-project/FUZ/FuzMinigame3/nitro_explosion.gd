extends Marker2D


func _on_cpu_particles_2d_finished() -> void:
	queue_free()
