extends CharacterBody2D

const SPEED = 0.5
@export var time_scale: float = 1
@export var destination: Vector2

@onready var hit_se: AudioStreamPlayer2D = $hitSE
const HIT_SE = preload("res://AG/AGMinigame1/hit_se.tscn")
const BOULDERCHUNK = preload("res://AG/AGMinigame1/boulderchunk.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.look_at(Vector2(0,0))
	scale=Vector2(0.5,0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_toward(0,0,delta)
	position += (destination - position).normalized()*SPEED*time_scale
	rotation += 0.01
	#global_position=Vector2(move_toward(self.global_position.x,destination.x,SPEED*delta),move_toward(self.global_position.y,destination.y,SPEED*delta))

func disappear() -> void:
	var instance = HIT_SE.instantiate()
	instance.pitch_scale=randf_range(2,2.5)
	instance.global_position=global_position
	instance.volume_db=-7
	get_parent().add_child(instance)
	
	for i in randi_range(3,6):
		var instance2 = BOULDERCHUNK.instantiate()
		instance2.global_position = global_position
		get_parent().add_child(instance2)
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	disappear()

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	get_parent().score_set.emit()
	disappear()
