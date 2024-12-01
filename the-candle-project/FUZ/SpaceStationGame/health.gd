extends Marker2D

func display_hearts(health):	
	for c in get_children():
		c.queue_free()
	
	const HEART = preload("res://FUZ/SpaceStationGame/heart.tscn")
	
	const OFFSET = 100
	if health > 0:
		for a in health:
			var new_heart = HEART.instantiate()
			add_child(new_heart)
			new_heart.position = Vector2(OFFSET * a, 0)
