extends Area2D

signal catch_ball
signal catch_object


func _on_area_entered(area: Area2D) -> void:
	if area.has_signal("ball_sig"):
		catch_ball.emit(area.weight_value)
	if area.has_signal("object_sig"):
		catch_object.emit(area)
	area.queue_free()
