extends RigidBody2D

class_name boulder

@onready var hit_se: AudioStreamPlayer2D = $hitSE
const HIT_SE = preload("res://AG/AGMinigame1/hit_se.tscn")
const BOULDERCHUNK = preload("res://AG/AGMinigame1/boulderchunk.tscn")

func _ready() -> void:
	apply_central_force(Vector2(randf_range(-1,1),0.3)*30000)

func _physics_process(delta: float) -> void:
	global_rotation+=4*delta


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	var instance = HIT_SE.instantiate()
	instance.pitch_scale=randf_range(2,2.5)
	instance.global_position=global_position
	instance.volume_db=-7
	get_parent().add_child(instance)
	
	for i in randi_range(3,6):
		var instance2 = BOULDERCHUNK.instantiate()
		instance2.global_position = global_position
		get_parent().add_child(instance2)

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
