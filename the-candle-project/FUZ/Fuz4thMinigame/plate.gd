extends Area2D

var has_weight_immunity = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weight_immunity_lifespan: Timer = $WeightImmunityLifespan
@onready var weight_immunity_death: Timer = $WeightImmunityDeath

signal catch_ball
signal catch_object

func _on_area_entered(area: Area2D) -> void:
	if area.has_signal("ball_sig"):
		catch_ball.emit(area)
	if area.has_signal("object_sig"):
		catch_object.emit(area)
	area.queue_free()


func _on_weight_immunity_lifespan_timeout() -> void:
	weight_immunity_death.start()
	animated_sprite.play()

func _on_weight_immunity_death_timeout() -> void:
	animated_sprite.stop()
	has_weight_immunity = false
	animated_sprite.frame = 0
