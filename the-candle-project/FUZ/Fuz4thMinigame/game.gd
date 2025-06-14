extends Node2D

var ball_timer = 0
var ball_spawn_time = 25
var weight_limit = 50.0
var score = 0
var health = 10.0

const ALERT = preload("res://FUZ/Fuz4thMinigame/alert.tscn")
const DOG = preload("res://FUZ/Fuz4thMinigame/dog.tscn")

@onready var player: CharacterBody2D = $Player
@onready var weight_limit_label: Label = $WeightLimitLabel
@onready var increase_limit: Timer = $IncreaseLimit
@onready var score_label: Label = $ScoreLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var limit_fall_sfx: AudioStreamPlayer2D = $LimitFallSFX
@onready var fall_timer: Timer = $FallTimer
@onready var dog_timer: Timer = $DogTimer


func _ready():
	player.weight_limit = weight_limit
	weight_limit_label.text = str(round(weight_limit))

func _physics_process(delta: float) -> void:
	ball_timer += 1
	if ball_timer >= ball_spawn_time:
		ball_timer = 0
		var spawn_roll = randf()
		if spawn_roll < 0.03:
			#spawn powerup
			pass
		if spawn_roll >= 0.03 && spawn_roll < 0.08:
			spawn_hazard()
		if spawn_roll >= 0.08:
			spawn_ball()
			
func spawn_hazard():
	const BALL = preload("res://FUZ/Fuz4thMinigame/falling_object.tscn")
	var new_ball = BALL.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	var r_xpos = round(randf() * rect.size.x)
	new_ball.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
	new_ball.direction = Vector2.DOWN
	new_ball.speed = 200
	new_ball.type = "bomb"
	new_ball.get_node("Bomb").visible = true
	add_child(new_ball)
	
func spawn_ball():
	const BALL = preload("res://FUZ/Fuz4thMinigame/ball.tscn")
	var new_ball = BALL.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	var r_xpos = round(randf() * rect.size.x)
	new_ball.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
	new_ball.direction = Vector2.DOWN
	new_ball.speed = 200
	var r = 0
	var rarity_roll = randf()
	var rarity = 0
	var percent = 0.2
	if rarity_roll < 0.05:
		r = floor(randf() * 10)
		rarity = 2
		percent = 0.7 + 0.05*r
		r = r + 8
	if rarity_roll < 0.3 && rarity_roll >= 0.05:
		r = floor(randf() * 4)
		rarity = 1
		percent = 0.30 + 0.05*r
		r = r + 4
	if rarity_roll >= 0.3:
		r = floor(randf() * 4)
		rarity = 0
		percent = 0.05 + 0.05*r
	new_ball.weight_value = round(5.0 + 5.0*r)
	if new_ball.weight_value == 0:
		new_ball.weight_value = 1
	new_ball.get_node("Label").text = str(new_ball.weight_value)
	new_ball.get_node("AnimatedSprite2D").frame = rarity
	add_child(new_ball)


func _on_increase_limit_timeout() -> void:
	var decrease_roll = floor(randf() * 4)
	print(decrease_roll)
	if weight_limit == 100.0:
		decrease_roll = 3
	if weight_limit == 10.0:
		decrease_roll = 0
	if decrease_roll == 3:
		limit_fall_sfx.play()
		fall_timer.start()
	else:
		if weight_limit == 10.0:
			weight_limit = 50.0
		else:
			var r = floor(randf() * 5)
			weight_limit = weight_limit + (3.0 + 3.0*r)
			if weight_limit > 100.0:
				weight_limit = 100.0
		player.weight_limit = weight_limit
		weight_limit_label.text = str(round(weight_limit))
		player.move_plates()
		
func _on_decrease_timeout():
		if weight_limit == 100.0:
			weight_limit = 50.0
		else:
			var r = 5 + floor(randf() * 7)
			weight_limit = weight_limit - (3.0 + 3.0*r)
			if weight_limit < 10.0:
				weight_limit = 10.0
		player.weight_limit = weight_limit
		weight_limit_label.text = str(round(weight_limit))
		player.move_plates()
	
func increase_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

func _on_game_area_area_exited(area: Area2D) -> void:
	area.queue_free()


func _on_player_ball_score(weight_value) -> void:
	const BASE_SCORE = 10.0
	#print("SCORED WITHOUT MULT " + str(round(BASE_SCORE * (weight_value/weight_limit))))
	var amount = round(pow(BASE_SCORE * (weight_value/50.0), 1.1))
	increase_score(amount)
	#print("SCORED " + str(amount))


func _on_player_bounce_bomb() -> void:
	increase_score(10)


func _on_player_player_hurt(amount) -> void:
	health += amount
	health_bar.value = health


func _on_fall_timer_timeout() -> void:
	_on_decrease_timeout()


func _on_game_area_body_exited(body: Node2D) -> void:
	body.queue_free()
	
func _on_dog_alert_timeout(alert):
	var new_dog = DOG.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	if alert.side == 0:
		new_dog.global_position = Vector2(rect.position.x, 165)
		new_dog.direction = 1
	if alert.side == 1:
		new_dog.global_position = Vector2(rect.end.x, 165)
		new_dog.direction = -1
	add_child(new_dog)
	dog_timer.start()

func _on_dog_timer_timeout() -> void:
	var new_alert = ALERT.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	var r = round(randf())
	if r == 0:
		new_alert.global_position = Vector2(rect.position.x + 100, 165)
	if r == 1:
		new_alert.global_position = Vector2(rect.end.x - 100, 165)
	new_alert.side = r
	new_alert.life_span = 120
	new_alert.alert_timeout.connect(_on_dog_alert_timeout)
	add_child(new_alert)
	
