extends GPUParticles2D

func _ready() -> void:
	self.emitting=true
	self.texture=load("res://AG/AGMinigame1/MiniAsteroids" + str(randi_range(1,3)) + ".png")

func _on_finished() -> void:
	queue_free()
