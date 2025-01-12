extends CharacterBody2D

const SPEED = 250.0
@export var luck:int = 1
@export var type:String = "coin"

func _ready() -> void:
	if self.type=="heart":
		get_child(0).animation="heart"
		self.scale=Vector2(2,2)
	else:
		var chance:int = randi_range(0,100)*luck
		if chance>=99:
			get_child(0).animation="coinbag"
			self.scale=Vector2(1.5,1.5)

func _physics_process(delta: float) -> void:
	position.y+=SPEED*delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if get_child(0).animation=="default":
		get_parent().coin_collect.emit(1)
	elif get_child(0).animation=="coinbag":
		get_parent().coin_collect.emit(10)
	elif get_child(0).animation=="heart":
		get_parent().health_change.emit(1)
	queue_free()


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	queue_free()
