extends CharacterBody2D

signal shoot

func _physics_process(delta: float) -> void:
		var direction = Input.get_vector("move_left", "move_right", "jump", "move_down")
		velocity = direction * 300
		
		if Input.is_action_just_pressed("shoot"):
			shoot.emit()
		move_and_slide()
