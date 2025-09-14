extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -450.0
var weight_limit = 5.0
var weight = 0.0

signal ball_score
signal bounce_bomb
signal player_hurt
signal catch_object

@onready var left_plate: Area2D = $LeftPlate
@onready var right_plate: Area2D = $RightPlate
@onready var weight_label: Label = $WeightLabel
@onready var warning: Sprite2D = $Warning

func _ready():
	left_plate.global_position.y = global_position.y
	right_plate.global_position.y = global_position.y
	update_weight_label()
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()


func _on_left_plate_catch_ball(ball) -> void:
	if !left_plate.has_weight_immunity:
		weight -= ball.weight_value
	if left_plate.has_weight_immunity:
		weight -= round(ball.weight_value/2)
	if weight < -weight_limit:
		hurt()
	move_plates()
	ball_score.emit(ball)


func _on_right_plate_catch_ball(ball) -> void:
	if !right_plate.has_weight_immunity:
		weight += ball.weight_value
	if right_plate.has_weight_immunity:
		weight += round(ball.weight_value/2)
	if weight > weight_limit:
		hurt()
	move_plates()
	ball_score.emit(ball)
	
func hurt():
	const BASE_HEALTH_LOSS = 1.0
	var percent = abs(weight / weight_limit)
	player_hurt.emit(-BASE_HEALTH_LOSS*percent)
	
func update_weight_label():
	weight_label.text = str("+" if weight >= 0 else "-") + str(abs(weight))
	weight_label.add_theme_color_override("font_color", Color(0, 0.8, 0) if weight >= 0 else Color(1, 0, 0))
	if weight*sign(weight) > weight_limit:
		warning.visible = true
	else:
		warning.visible = false
	
func move_plates():
	const MAX_DISTANCE = 16.0
	var capped_weight = weight
	if weight*sign(weight) > weight_limit:
		capped_weight = weight_limit*sign(weight)
	var percent = capped_weight / weight_limit
	left_plate.global_position.y = global_position.y
	right_plate.global_position.y = global_position.y
	left_plate.global_position.y -= MAX_DISTANCE*percent
	right_plate.global_position.y += MAX_DISTANCE*percent
	update_weight_label()
	


func _on_left_plate_catch_object(area) -> void:
	catch_object.emit(area, left_plate)


func _on_right_plate_catch_object(area) -> void:
	catch_object.emit(area, right_plate)

func _on_head_box_area_entered(area: Area2D) -> void:
	if area.type == "bomb":
		area.direction = Vector2.UP
		area.speed = 400
		bounce_bomb.emit(area)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	player_hurt.emit(-2.5)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.type == "shuriken":
		if area.boss:
			player_hurt.emit(-1.0)
		if !area.boss:
			player_hurt.emit(-2.5)
	area.queue_free()
