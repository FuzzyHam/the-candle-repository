extends Area2D

var range = 150
var speed = 2
var origin
var side = 1
var axis = "x"
var collision_ready = false

signal create_crawler

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	origin = global_position.x

func _physics_process(delta: float) -> void:
	if (global_position.x + speed*side) * side > (origin + range*side) * side:
		side = side * -1
	
	global_position.x += speed*side
	
	if collision_ready:
		if !has_overlapping_bodies():
			create_crawler.emit(self)
			
	if !collision_ready:
		if has_overlapping_bodies():
			collision_ready = true
