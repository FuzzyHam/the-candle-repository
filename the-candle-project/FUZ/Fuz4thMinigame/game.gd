extends Node2D

var ball_timer = 0
var ball_spawn_time = 40
var weight_limit = 50.0
var score = 0
var health = 10.0
var food_goal_type = 0
var food_goal_value = 10
var current_boost = null
var powerup_ready = false
var current_ninja = null
var boss_mode = false
var ninja_counter = 0
var orders_completed = 0
var bounty_victory = false
var employee_victory = false
var safety_victory = false

const ALERT = preload("res://FUZ/Fuz4thMinigame/alert.tscn")
const DOG = preload("res://FUZ/Fuz4thMinigame/dog.tscn")
const SCORE_BOOST = preload("res://FUZ/Fuz4thMinigame/score_boost.tscn")
const BALL = preload("res://FUZ/Fuz4thMinigame/ball.tscn")
const FALLING_OBJECT = preload("res://FUZ/Fuz4thMinigame/falling_object.tscn")
const NINJA = preload("res://FUZ/Fuz4thMinigame/ninja.tscn")
const SHURIKEN = preload("res://FUZ/Fuz4thMinigame/shuriken.tscn")
const SMOKE_BOMB = preload("res://FUZ/Fuz4thMinigame/smoke_bomb.tscn")
const CHECK = preload("res://FUZ/Fuz4thMinigame/check.tscn")

@onready var player: CharacterBody2D = $Player
@onready var weight_limit_label: Label = $WeightLimitLabel
@onready var increase_limit: Timer = $IncreaseLimit
@onready var score_label: Label = $ScoreLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var limit_fall_sfx: AudioStreamPlayer2D = $LimitFallSFX
@onready var fall_timer: Timer = $FallTimer
@onready var dog_timer: Timer = $DogTimer
@onready var food_goal: Marker2D = $FoodGoal
@onready var load_player: Node2D = $LoadPlayer
@onready var powerup_spawn: Timer = $PowerupSpawn
@onready var pickup_food_sfx: AudioStreamPlayer2D = $SFX/PickupFoodSFX
@onready var pickup_powerup_sfx: AudioStreamPlayer2D = $SFX/PickupPowerupSFX
@onready var hurt_sfx: AudioStreamPlayer2D = $SFX/HurtSFX
@onready var smoke_bomb_sfx: AudioStreamPlayer2D = $SFX/SmokeBombSFX
@onready var ninja_hit_sfx: AudioStreamPlayer2D = $SFX/NinjaHitSFX
@onready var ninja_spawn: Timer = $NinjaSpawn
@onready var ninja_bonus_label: Label = $NinjaBonusLabel
@onready var boss_death_time: Timer = $BossDeathTime
@onready var load_player_poster: Node2D = $LoadPlayerPoster
@onready var bounty_poster_2: Sprite2D = $Background/BountyPoster2
@onready var poster_avatar: CharacterBody2D = $Background/PosterAvatar
@onready var safety_poster_2: Sprite2D = $Background/SafetyPoster2
@onready var employee_poster: Sprite2D = $Background/EmployeePoster
@onready var background: Node2D = $Background


func _ready():
	player.weight_limit = weight_limit
	weight_limit_label.text = str(round(weight_limit))
	food_goal.get_node("Label").text = str(food_goal_value)
	load_player._on_load_character()
	load_player_poster._on_load_character()

func _physics_process(delta: float) -> void:
	ball_timer += 1
	if !boss_mode:
		if ball_timer >= ball_spawn_time:
			ball_timer = 0
			var already_spawned = false
			if powerup_ready:
				spawn_falling_object("powerup")
				already_spawned = true
				powerup_ready = false
				powerup_spawn.wait_time = round(randf_range(15, 30))
				powerup_spawn.start()
			if !already_spawned:
				var spawn_roll = randf()
				if spawn_roll < 0.05:
					spawn_falling_object("hazard")
				if spawn_roll >= 0.05:
					spawn_ball()
	if boss_mode:
		if !current_ninja.boss_dead:
			if ball_timer >= 50:
				ball_timer = 0
				spawn_falling_object("hazard")
		if current_ninja.boss_dead:
			if ball_timer >= 10:
				ball_timer = 0
				spawn_boss_ball()
	if current_ninja:
		ninja_process()
				
func ninja_process():
	current_ninja.switch_time_count += 1
	if current_ninja.switch_time_count >= current_ninja.switch_time:
		var r = randf()
		if r > 0.75:
			if current_ninja.dir == 1:
				current_ninja.dir = -1
				current_ninja.animated_sprite.flip_h = false
			else:
				current_ninja.dir = 1
				current_ninja.animated_sprite.flip_h = true
		current_ninja.switch_time_count = 0
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	if current_ninja.global_position.x < rect.position.x + 64:
		current_ninja.dir = 1
		current_ninja.animated_sprite.flip_h = true
	if current_ninja.global_position.x > rect.end.x - 64:
		current_ninja.dir = -1
		current_ninja.animated_sprite.flip_h = false
	current_ninja.global_position.x += 3*current_ninja.dir
	
	if !current_ninja.boss_dead:
		current_ninja.shoot_time_count += 1
		if current_ninja.shoot_time_count >= current_ninja.shoot_time:
			ninja_shoot()
			current_ninja.shoot_time_count = 0
	
func ninja_shoot():
	if !current_ninja.boss:
		var shuriken = SHURIKEN.instantiate()
		shuriken.global_position = current_ninja.global_position
		shuriken.look_at(player.global_position)
		add_child(shuriken)
	
	if current_ninja.boss:
		var deg = -40
		for s in 5:
			var shuriken2 = SHURIKEN.instantiate()
			shuriken2.global_position = current_ninja.global_position
			shuriken2.look_at(player.global_position)
			shuriken2.rotation_degrees += deg
			deg += 20
			shuriken2.speed = 300
			shuriken2.boss = true
			add_child(shuriken2)
			
func spawn_falling_object(mode):
	var new_obj = FALLING_OBJECT.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	var r_xpos = round(randf() * rect.size.x)
	new_obj.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
	new_obj.direction = Vector2.DOWN
	new_obj.speed = 200
	if mode == "hazard":
		new_obj.type = "bomb"
		new_obj.get_node("Bomb").visible = true
	if mode == "powerup":
		var r = round(randf())
		if r == 0:
			new_obj.type = "weight_immunity"
			new_obj.get_node("WeightImmunity").visible = true
		if r == 1:
			new_obj.type = "paycheck"
			new_obj.get_node("PayCheck").visible = true
	add_child(new_obj)
	
func spawn_boss_ball():
	var new_ball = BALL.instantiate()
	new_ball.global_position = current_ninja.global_position
	new_ball.direction = Vector2.DOWN
	new_ball.speed = 200
	new_ball.weight_value = 5
	new_ball.get_node("Label").text = str(new_ball.weight_value)
	new_ball.food_type = 5
	new_ball.get_node("AnimatedSprite2D").frame = new_ball.food_type
	add_child(new_ball)
	
func spawn_ball():
	var new_ball = BALL.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	var r_xpos = round(randf() * rect.size.x)
	new_ball.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
	new_ball.direction = Vector2.DOWN
	new_ball.speed = 200
	var r = 0
	var rarity_roll = randf()
	if rarity_roll < 0.25:
		r = floor(randf() * 10)
		r = r + 12
	if rarity_roll < 0.6 && rarity_roll >= 0.25:
		r = floor(randf() * 6)
		r = r + 6
	if rarity_roll >= 0.6:
		r = floor(randf() * 6)
	new_ball.weight_value = float(round(5.0 + 5.0*r))
	if new_ball.weight_value == 0:
		new_ball.weight_value = 1.0
	new_ball.get_node("Label").text = str(new_ball.weight_value)
	var random_type = floor(randf() * 5)
	new_ball.food_type = random_type if random_type != 5 else 4
	new_ball.get_node("AnimatedSprite2D").frame = new_ball.food_type
	add_child(new_ball)


func _on_increase_limit_timeout() -> void:
	if boss_mode:
		return
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
			change_weight_limit(50.0)
		else:
			var r = floor(randf() * 5)
			change_weight_limit(weight_limit + (3.0 + 3.0*r))
			if weight_limit > 100.0:
				change_weight_limit(100.0)
		
func _on_decrease_timeout():
	if boss_mode:
		return
	if weight_limit == 100.0:
		change_weight_limit(50.0)
	else:
		var r = 5 + floor(randf() * 7)
		change_weight_limit(weight_limit - (3.0 + 3.0*r))
		if weight_limit < 10.0:
			change_weight_limit(10.0)
	
func increase_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)
	if score >= 2000 && !safety_victory:
		safety_victory = true
		safety_poster_2.visible = true
		add_check(safety_poster_2)

func _on_game_area_area_exited(area: Area2D) -> void:
	print(area)
	area.queue_free()


func _on_player_ball_score(ball) -> void:
	if ball.food_type != 5:
		const BASE_SCORE = 10.0
		#print("SCORED WITHOUT MULT " + str(round(BASE_SCORE * (weight_value/weight_limit))))
		var amount = pow(BASE_SCORE * (ball.weight_value/weight_limit), 1.1)
		if current_ninja:
			amount = amount * 1.25
		if current_boost:
			amount = amount * current_boost.boost_multiplier
		increase_score(round(amount))
		#print("SCORED " + str(amount))
	if ball.food_type == 5:
		increase_score(5)
	if ball.food_type == food_goal_type:
		food_goal_value -= 1
		food_goal.get_node("Label").text = str(food_goal_value)
		if food_goal_value == 0:
			order_finish()
	pickup_food_sfx.play()

func order_finish():
	if current_boost:
		current_boost.queue_free()
		current_boost = null
	var boost = SCORE_BOOST.instantiate()
	boost.global_position = Vector2(0, -255)
	boost.boost_end.connect(_on_boost_end)
	current_boost = boost
	add_child(boost)
	var r = floor(randf() * 5)
	food_goal_type = r if r != 5 else 4
	food_goal.get_node("AnimatedSprite2D").frame = food_goal_type
	food_goal_value = 10
	food_goal.get_node("Label").text = str(food_goal_value)
	orders_completed += 1
	if orders_completed >= 3 && !employee_victory:
		employee_victory = true
		poster_avatar.visible = true
		add_check(employee_poster)

func _on_catch_object(area, plate):
	if area.type == "bomb":
		if !boss_mode:
			_on_player_hurt(-2.5)
		if boss_mode:
			_on_player_hurt(-1.0)
	if area.type == "weight_immunity":
		print("weight max" + str(plate.name))
		plate.has_weight_immunity = true
		plate.animated_sprite.frame = 1
		plate.weight_immunity_lifespan.start()
		pickup_powerup_sfx.play()
	if area.type == "paycheck":
		_on_player_hurt(3.3)
		pickup_powerup_sfx.play()

func _on_boost_end(boost):
	current_boost = null
	pass


func _on_player_bounce_bomb(bomb) -> void:
	bomb.rebound = true
	if !boss_mode:
		increase_score(20)


func _on_player_hurt(amount) -> void:
	health += amount
	if amount < 0:
		hurt_sfx.play()
	if health > 10:
		health = 10
	if health <= 0:
		get_tree().reload_current_scene()
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
	dog_timer.wait_time = round(randf_range(5, 15))
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
	


func _on_powerup_spawn_timeout() -> void:
	powerup_ready = true
	

func _on_ninja_lifespan_end():
	ninja_smoke()
	current_ninja.queue_free()
	current_ninja = null
	ninja_spawn.start()
	ninja_bonus_label.visible = false
	
func _on_ninja_killed():
	if !current_ninja.boss:
		current_ninja.animated_sprite.animation = "default-dead"
		current_ninja.falling = true
		current_ninja = null
		ninja_spawn.start()
		ninja_bonus_label.visible = false
	if current_ninja.boss:
		current_ninja.animated_sprite.animation = "grand-dead"
		current_ninja.boss_dead = true
		boss_death_time.start()
		if !bounty_victory:
			bounty_victory = true
			bounty_poster_2.visible = true
			add_check(bounty_poster_2)
	
	
func add_check(poster):
	var check = CHECK.instantiate()
	check.global_position = poster.global_position
	check.global_position.y += 32
	background.add_child(check)
	
func _on_ninja_hit():
	ninja_hit_sfx.play()

func _on_ninja_spawn_timeout() -> void:
	var ninja = NINJA.instantiate()
	var rect = get_node("GameCenter/GameArea/CollisionShape2D").shape.get_rect()
	ninja.global_position.x = rect.position.x + (rect.end.x-rect.position.x)/2
	ninja.global_position.y = rect.position.y + 80
	ninja.lifespan_end.connect(_on_ninja_lifespan_end)
	ninja.killed.connect(_on_ninja_killed)
	ninja.hit.connect(_on_ninja_hit)
	add_child(ninja)
	current_ninja = ninja
	ninja_smoke()
	ninja_bonus_label.visible = true
	
	ninja_counter += 1
	
	if ninja_counter == 5:
		ninja.boss = true
		ninja.animated_sprite.animation = "grand"
		boss_mode = true
		ninja.shoot_time = 120
		ninja_bonus_label.visible = false
		change_weight_limit(50.0)
	
func change_weight_limit(new_limit):
	weight_limit = new_limit
	player.weight_limit = weight_limit
	weight_limit_label.text = str(round(weight_limit))
	player.move_plates()

func ninja_smoke():
	var smoke_bomb = SMOKE_BOMB.instantiate()
	smoke_bomb.global_position = current_ninja.global_position
	add_child(smoke_bomb)
	smoke_bomb_sfx.play()


func _on_boss_death_time_timeout() -> void:
	boss_mode = false
	current_ninja.falling = true
	current_ninja = null
	ninja_spawn.start()
