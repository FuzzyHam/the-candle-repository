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
	new_bubble.explode.connect(on_bubble_explode)
	add_child(new_bubble)
	
func _on_bubble_hurt():
	health -= 1
	print(health)
	
func _on_bubble_bullet_hurt():
	health -= 1
	print(health)
	
func on_bubble_explode(bubble):
	var deg = 0
	const BUBBLE_BULLET = preload("res://FUZ/FuzMinigame2/bubble_bullet.tscn")
	for a in 9:
		var new_bubble_bullet = BUBBLE_BULLET.instantiate()
		new_bubble_bullet.global_position = bubble.global_position
		new_bubble_bullet.rotation_degrees = deg
		deg += 40
		new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
		call_deferred("add_child", new_bubble_bullet)



func _on_player_shoot() -> void:
	const BULLET = preload("res://FUZ/FuzMinigame2/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = player.global_position
	new_bullet.look_at(get_global_mouse_position())
	add_child(new_bullet)


func _on_strider_strider_shoot(strider) -> void:
		const BUBBLE_BULLET = preload("res://FUZ/FuzMinigame2/bubble_bullet.tscn")
		var side = 1
		for a in 2:
			var new_bubble_bullet = BUBBLE_BULLET.instantiate()
			new_bubble_bullet.global_position = strider.global_position
			new_bubble_bullet.global_rotation = strider.global_rotation
			new_bubble_bullet.rotation_degrees += 90 * side
			new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
			call_deferred("add_child", new_bubble_bullet)
			side = -1
