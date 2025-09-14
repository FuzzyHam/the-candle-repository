extends CharacterBody2D

const BULLET = preload("res://AG/AGMinigame2/bullet.tscn")

@onready var character_loader: Node = %CharacterLoader

@onready var back_layer: ParallaxLayer = %BackLayer
@onready var mid_layer: ParallaxLayer = %MidLayer
@onready var front_layer: ParallaxLayer = %FrontLayer
@onready var shoot_mark: Marker2D = $ShootMark
@onready var player_energy: RichTextLabel = %PlayerEnergy
@onready var energy_regen: Timer = $energyRegen

var energy: int = 10

var d := 1.6
var radius := 96
var speed := 1

signal shoot

func _ready() -> void:
	character_loader._on_load_character()
	scale=Vector2(0.5,0.5)
	shoot.connect(_on_shoot)

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right")||Input.is_action_pressed("jump"):
		d-=delta*speed*get_parent().timeScale
		rotation+=delta*speed*speed*2*get_parent().timeScale
	elif Input.is_action_pressed("move_left")||Input.is_action_pressed("move_down"):
		d+=delta*speed*get_parent().timeScale
		rotation-=delta*speed*speed*2*get_parent().timeScale
	
	if Input.is_action_just_pressed("shoot"):
		shoot.emit()

	
	position = Vector2(
		sin(d*speed*2)*radius,
		cos(d*speed*2)*radius
	) + Vector2(576,312)
	
	back_layer.motion_offset=position*back_layer.motion_scale+((position)-(Vector2(576,192.0)))*0.001
	mid_layer.motion_offset=position*mid_layer.motion_scale+((position)-(Vector2(576,192.0)))*0.005
	front_layer.motion_offset=position*front_layer.motion_scale+((position)-(Vector2(576,192.0)))*0.01

func _on_shoot() -> void:
	if energy>0:
		energy-=1
		var instance = BULLET.instantiate()
		instance.global_position=shoot_mark.global_position
		instance.rotation=self.rotation
		get_tree().root.add_child(instance)
		update_energy_text()

func update_energy_text() -> void:
	player_energy.text="PLAYER ENERGY: " + str(energy) + "/10"

func _on_energy_regen_timeout() -> void:
	if energy<10:
		energy+=1
		update_energy_text()
