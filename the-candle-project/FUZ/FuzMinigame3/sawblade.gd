extends Area2D

var range = 150
var speed = 2
var origin
var side = 1
var axis = "x"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	origin = global_position.x

func _physics_process(delta: float) -> void:
	if (global_position.x + speed*side) * side > (origin + range*side) * side:
		side = side * -1
	
	global_position.x += speed*side
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_signal("hurt"):
		body.hurt.emit(-1)
