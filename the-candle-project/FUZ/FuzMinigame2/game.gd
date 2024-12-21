extends Node2D

@onready var game_area: Area2D = $GameCenter/GameArea
@onready var boundary: StaticBody2D = $GameCenter/Boundary
@onready var game_center: Marker2D = $GameCenter
@onready var player: CharacterBody2D = $Player
@onready var bubble_reload: Timer = $BubbleReload
@onready var health_display: Marker2D = $HealthDisplay
@onready var score_display: Label = $ScoreDisplay
@onready var load_player: Node2D = $LoadPlayer
@onready var water_boundary: Node2D = $WaterBoundary
@onready var strider_spawn: Timer = $StriderSpawn
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSFX
@onready var flower_sfx: AudioStreamPlayer2D = $FlowerSFX
@onready var goal: Label = $Goal


signal reset_game

var health = 5
var bubble_counter = 0
var score = 0
var achievements = []
var lock_every_bubble_achievement = false
var base_bubble_reload = 0.8
var water_distance = 0.0
var water_overlap_time = 0
var mega_rarity = 0.8
const WATER_LIMIT = 200.0
var flower_spacing = 25
var danger_spacing = 20
var flower_offset = flower_spacing
var danger_offset = danger_spacing

func _ready():
	#var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	#boundary.get_node("Left").position.x = rect.position.x
	#boundary.get_node("Right").position.x = rect.end.x
	#boundary.get_node("Top").position.y = rect.position.y
	#boundary.get_node("Bottom").position.y = rect.end.y
	health_display.get_node("Label").text = "x" + str(health)

	water_boundary.get_node("UpBound").position.y = boundary.get_node("Top").position.y + 20
	water_boundary.get_node("DownBound").position.y = boundary.get_node("Bottom").position.y
	water_boundary.get_node("RightBound").position.x = boundary.get_node("Right").position.x
	water_boundary.get_node("LeftBound").position.x = boundary.get_node("Left").position.x + 20
	var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	water_boundary.get_node("UpRect").position.y = rect.position.y
	water_boundary.get_node("UpRect").size.y = 0
	water_boundary.get_node("UpRect").position.x = rect.position.x
	water_boundary.get_node("UpRect").size.x = abs(rect.end.x - rect.position.x)
	water_boundary.get_node("DownRect").position.y = rect.end.y - 0
	water_boundary.get_node("DownRect").size.y = 0
	water_boundary.get_node("DownRect").position.x = rect.position.x
	water_boundary.get_node("DownRect").size.x = abs(rect.end.x - rect.position.x)
	water_boundary.get_node("RightRect").position.y = rect.position.y
	water_boundary.get_node("RightRect").size.y = abs(rect.end.y - rect.position.y)
	water_boundary.get_node("RightRect").position.x = rect.end.x - 0
	water_boundary.get_node("RightRect").size.x = 0
	water_boundary.get_node("LeftRect").position.y = rect.position.y
	water_boundary.get_node("LeftRect").size.y = abs(rect.end.y - rect.position.y)
	water_boundary.get_node("LeftRect").position.x = rect.position.x
	water_boundary.get_node("LeftRect").size.x = 0
	water_boundary.modulate = Color(1, 1, 1, 0.5)

	load_player._on_load_character() 
	
func _physics_process(delta: float) -> void:
	water_distance += 0.02
	if water_distance > WATER_LIMIT:
		water_distance = WATER_LIMIT
	var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	water_boundary.get_node("UpRect").size.y = water_distance
	water_boundary.get_node("UpBound").position.y = rect.position.y + water_distance
	water_boundary.get_node("DownRect").position.y = rect.end.y - water_distance
	water_boundary.get_node("DownRect").size.y = water_distance
	water_boundary.get_node("DownBound").position.y = rect.end.y - water_distance
	water_boundary.get_node("RightRect").position.x = rect.end.x - water_distance
	water_boundary.get_node("RightRect").size.x = water_distance
	water_boundary.get_node("RightBound").position.x = rect.end.x - water_distance
	water_boundary.get_node("LeftRect").size.x = water_distance
	water_boundary.get_node("LeftBound").position.x = rect.position.x + water_distance
	if player.get_node("HurtBox").get_overlapping_areas().size() > 0:
		if water_overlap_time == 0 || water_overlap_time >= 60:
			change_health(-1)
			hurt_sfx.play()
			water_overlap_time = 0
		water_overlap_time += 1

func _on_bubble_reload_timeout() -> void:
	const BUBBLE = preload("res://FUZ/FuzMinigame2/bubble.tscn")
	var new_bubble = BUBBLE.instantiate()
	game_area.get_node("Path2D/PathFollow2D").progress_ratio = randf()
	new_bubble.global_position = game_area.get_node("Path2D/PathFollow2D").global_position
	new_bubble.look_at(game_center.global_position)
	new_bubble.hurt.connect(_on_bubble_hurt)
	new_bubble.explode.connect(_on_bubble_explode)
	new_bubble.score_gain.connect(_on_bubble_score_gain)
	new_bubble.lifespan_die.connect(_on_lifespan_die)
	bubble_counter += 1
	new_bubble.modulate = Color(0.2, 0.6, 1, 1)
	new_bubble.bubble_type = "normal"
	if flower_offset == danger_offset:
		flower_offset += 1
	if bubble_counter == flower_offset:
		new_bubble.bubble_type = "flower"
		new_bubble.get_node("LifeSpan1").stop()
		new_bubble.get_node("LifeSpan2").stop()
		new_bubble.get_node("AnimatedSprite2D").autoplay = "flower"
		new_bubble.get_node("AnimatedSprite2D").play("flower")
		new_bubble.modulate = Color(1, 1, 1, 1)
		flower_offset += flower_spacing
	if bubble_counter == danger_offset:
		new_bubble.bubble_type = "danger"
		new_bubble.modulate = Color(1, 0.6, 0.2, 1)
		new_bubble.danger_explode.connect(_on_danger_explode)
		danger_offset += danger_spacing
		danger_spacing -= 1
		if danger_spacing <= 5:
			danger_spacing = 5
	if new_bubble.bubble_type == "normal":
		var rtype = randf()
		if rtype > mega_rarity:
			new_bubble.bubble_type = "mega"
			new_bubble.modulate = Color(1, 0, 0, 1)
	add_child(new_bubble)
	var r = randf() - 0.5
	bubble_reload.wait_time = base_bubble_reload + r
	
	
func change_health(amount):
	health += amount
	health_display.get_node("Label").text = "x" + str(health)
	if health <= 0:
		reset_game.emit(self)
	
func _on_bubble_hurt():
	change_health(-1)
	hurt_sfx.play()
	
func _on_lifespan_die():
	lock_every_bubble_achievement = true
	
func _on_bubble_score_gain(bubble):
	if bubble.bubble_type == "normal":
		score += 1
	if bubble.bubble_type == "danger":
		score += 1
	if bubble.bubble_type == "flower":
		score += 2
	if bubble.bubble_type == "mega":
		score += 3
	score_display.text = str(score)
	if score >= 100 && !achievements.has("RIPPLES:WIN"):
		print("YOU WIN!!")
		print("Achievement: Get 100 points in ripples")
		achievements.append("RIPPLES:WIN")
		goal.add_theme_color_override("font_color", Color(0, 1, 0))
		if !lock_every_bubble_achievement:
			print("Achievement: Shoot all bubbles before they die and win the game")
			achievements.append("RIPPLES:EVERYBUBBLE")
	if score >= 150 && !achievements.has("RIPPLES:150POINTS"):
		print("Achievement: Get 150 points in ripples")
		achievements.append("RIPPLES:150POINTS")
		
	
func _on_bubble_bullet_hurt(bubble_bullet):
	if bubble_bullet.bullet_type != "flower":
		change_health(-1)
		hurt_sfx.play()
	if bubble_bullet.bullet_type == "flower":
		change_health(1)
		flower_sfx.play()
	
func _on_danger_explode(bubble):
	var deg = 0
	const BUBBLE_BULLET = preload("res://FUZ/FuzMinigame2/bubble_bullet.tscn")
	for a in 24:
		var new_bubble_bullet = BUBBLE_BULLET.instantiate()
		new_bubble_bullet.global_position = bubble.global_position
		new_bubble_bullet.rotation_degrees = deg
		deg += 15
		new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
		call_deferred("add_child", new_bubble_bullet)
	
func _on_bubble_explode(bubble):
	var deg = 0
	const BUBBLE_BULLET = preload("res://FUZ/FuzMinigame2/bubble_bullet.tscn")
	if bubble.bubble_type == "normal":
		for a in 6:
			var new_bubble_bullet = BUBBLE_BULLET.instantiate()
			new_bubble_bullet.global_position = bubble.global_position
			new_bubble_bullet.rotation_degrees = deg
			deg += 60
			new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
			call_deferred("add_child", new_bubble_bullet)
	if bubble.bubble_type == "mega":
		for a in 15:
			var new_bubble_bullet = BUBBLE_BULLET.instantiate()
			new_bubble_bullet.global_position = bubble.global_position
			new_bubble_bullet.rotation_degrees = deg
			deg += 24
			new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
			call_deferred("add_child", new_bubble_bullet)
	if bubble.bubble_type == "danger":
		for a in 12:
			var new_bubble_bullet = BUBBLE_BULLET.instantiate()
			new_bubble_bullet.global_position = bubble.global_position
			new_bubble_bullet.rotation_degrees = deg
			deg += 30
			new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
			call_deferred("add_child", new_bubble_bullet)
	if bubble.bubble_type == "flower":
		for a in 5:
			var new_bubble_bullet = BUBBLE_BULLET.instantiate()
			new_bubble_bullet.global_position = bubble.global_position
			new_bubble_bullet.rotation_degrees = deg
			deg += 72
			new_bubble_bullet.hurt.connect(_on_bubble_bullet_hurt)
			new_bubble_bullet.modulate = Color(1, 0.6, 1, 1)
			new_bubble_bullet.bullet_type = "flower"
			new_bubble_bullet.speed = 120
			call_deferred("add_child", new_bubble_bullet)
	




func _on_player_shoot() -> void:
	const BULLET = preload("res://FUZ/FuzMinigame2/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = player.global_position
	new_bullet.look_at(get_global_mouse_position())
	add_child(new_bullet)
	shoot_sfx.play()


func _on_strider_shoot(strider) -> void:
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

func _on_strider_spawn_timeout() -> void:
		const STRIDER = preload("res://FUZ/FuzMinigame2/strider.tscn")
		var new_strider = STRIDER.instantiate()
		var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
		#var r_xpos = round(randf() * rect.size.x)
		var r_xpos = round(randf() * 660.0)
		var side = round(randf())
		if side == 1:
			#new_strider.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
			new_strider.global_position = Vector2(-330.0 + r_xpos, rect.position.y)
			new_strider.global_rotation_degrees = 90
		if side == 0:
			#new_strider.global_position = Vector2(rect.position.x + r_xpos, rect.end.y)
			new_strider.global_position = Vector2(-330.0 + r_xpos, rect.end.y)
			new_strider.global_rotation_degrees = 270
		new_strider.shoot.connect(_on_strider_shoot)
		add_child(new_strider)
		
		mega_rarity -= 0.01
		strider_spawn.wait_time -= 0.2
		if strider_spawn.wait_time < 1:
			strider_spawn.wait_time = 1
		#print(strider_spawn.wait_time)
		#base_bubble_reload -= 0.05
		if base_bubble_reload < 0.6:
			base_bubble_reload = 0.6


func _on_game_area_area_exited(area: Area2D) -> void:
	if area.has_signal("lifespan_die"):
		if !area.shot:
			area.lifespan_die.emit()
	area.queue_free()
