extends GPUParticles2D

func _ready() -> void:
	self.emitting=true

func _on_finished() -> void:
	queue_free()
