extends Label

var opacity = 1.0

func _physics_process(delta: float) -> void:
	global_position.y -= 1
	remove_theme_color_override("font_color")
	add_theme_color_override("font_color", Color(1, 1, 1, opacity))
	opacity -= 0.02
	if opacity <= 0:
		queue_free()
