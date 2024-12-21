extends Node2D

var player_overlapping = 0

func _ready() -> void:
	for c in get_children():
		if c.is_class("Area2D"):
			c.body_entered.connect(_on_body_entered)
			c.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	player_overlapping += 1
	#print("overlap")
	#print(get_node("UpBound").position.y)
	
func _on_body_exited(body: Node2D):
	player_overlapping -= 1
	#print("exit")
