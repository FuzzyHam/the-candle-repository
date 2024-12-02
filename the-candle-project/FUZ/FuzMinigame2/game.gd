extends Node2D

@onready var game_area: Area2D = $GameCenter/GameArea
@onready var boundary: StaticBody2D = $GameCenter/Boundary
@onready var game_center: Marker2D = $GameCenter
@onready var player: CharacterBody2D = $Player

var health = 5

func _ready():
	var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	boundary.get_node("Left").position.x = rect.position.x
	boundary.get_node("Right").position.x = rect.end.x
	boundary.get_node("Top").position.y = rect.position.y
	boundary.get_node("Bottom").position.y = rect.end.y
	print(rect.end.x - rect.position.x)
	print(rect.end.y - rect.position.y)


func _on_bubble_reload_timeout() -> void:
	const BUBBLE = preload("res://FUZ/FuzMinigame2/bubble.tscn")
	var new_bubble = BUBBLE.instantiate()
	game_area.get_node("Path2D/PathFollow2D").progress_ratio = randf()
	new_bubble.global_position = game_area.get_node("Path2D/PathFollow2D").global_position
	new_bubble.look_at(game_center.global_position)
	new_bubble.hurt.connect(_on_bubble_hurt)
	add_child(new_bubble)
	
func _on_bubble_hurt():
	health -= 1
	print(health)


func _on_player_shoot() -> void:
	const BULLET = preload("res://FUZ/FuzMinigame2/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = player.global_position
	new_bullet.look_at(get_global_mouse_position())
	add_child(new_bullet)
