extends Area2D

var switch_time = 100
var switch_time_count = 0
var shoot_time = 90
var shoot_time_count = 0
var dir = 1
var boss = false
var falling = false
var health = 3
var boss_dead = false

signal lifespan_end
signal killed
signal hit

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if falling:
		global_position.y += 5

func _on_ninja_lifespan_timeout() -> void:
	if !falling && !boss:
		lifespan_end.emit()


func _on_area_entered(area: Area2D) -> void:
	if !falling:
		if area.type == "bomb" && area.rebound:
			area.queue_free()
			hit.emit()
			if !boss:
				killed.emit()
			if boss:
				health -= 1
				if health == 0:
					killed.emit()
