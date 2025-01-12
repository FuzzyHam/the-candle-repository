extends StaticBody2D

@export var type:String
const BAT = preload("res://AG/AGMinigame1/bat.tscn")

func _on_timer_timeout() -> void:
	match type:
		"bat":
			var instance = BAT.instantiate()
			instance.global_position=global_position
			get_parent().add_child(instance)
			queue_free()
		"upgrade1":
			pass
		"upgrade2":
			pass
		"upgrade3":
			pass
