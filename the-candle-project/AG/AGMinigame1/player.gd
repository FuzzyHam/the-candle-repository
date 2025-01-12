extends CharacterBody2D
class_name Player

@onready var character_loader: Node = $"../CharacterLoader"

const SPEED = 600.0
@onready var coin_ui: RichTextLabel = $"../CoinUI"

func _ready() -> void:
	character_loader._on_load_character()
	scale=Vector2(0.5,0.5) #set scale during ready since i love bandaid fixes

func _physics_process(delta: float) -> void:
	
	#movement code
	if Input.is_action_pressed("move_right"):
		velocity.x=SPEED
	elif Input.is_action_pressed("move_left"):
		velocity.x=-SPEED
	else: velocity.x=0
	
	if Input.is_action_pressed("jump"):
		velocity.y=-SPEED
	elif Input.is_action_pressed("move_down"):
		velocity.y=SPEED
	else: velocity.y=0
	
	velocity = velocity.normalized() * SPEED * delta * 50
	#cha cha slide
	move_and_slide()

func _on_boulder_sensor_area_entered(area: Area2D) -> void:
	get_parent().health_change.emit(-1)

func _on_bat_sensor_area_entered(area: Area2D) -> void:
	if area.get_parent().canHurt==true:
		get_parent().health_change.emit(-1)
