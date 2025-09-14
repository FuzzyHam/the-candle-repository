extends Node2D

const BOULDER = preload("res://AG/AGMinigame2/boulder.tscn")
const STAR = preload("res://AG/AGMinigame2/star.tscn")
const RADIUS := 850
const DEF_BOULDER_SPAWN_TIME: float = 3.0

var playerHealth: int = 3
var planetHealth: int = 3
var timeScale: float = 1
var score:=0
var combo_set:=1

@onready var music: AudioStreamPlayer = $Music
@onready var boulder_spawn: Timer = $BoulderSpawn

@onready var camera: Camera2D = %Camera
@onready var player: CharacterBody2D = %Player
@onready var planet: Sprite2D = $Planet

@onready var back_layer: ParallaxLayer = %BackLayer
@onready var mid_layer: ParallaxLayer = %MidLayer
@onready var front_layer: ParallaxLayer = %FrontLayer
@onready var player_health_text: RichTextLabel = %PlayerHealthText
@onready var planet_health_text: RichTextLabel = %PlanetHealthText
@onready var combo_text: RichTextLabel = %ComboText
@onready var score_text: RichTextLabel = %ScoreText


signal score_set

func _ready() -> void:
	#play music
	music.play()
	music.stream.set_sync_stream_volume(1,-60)
	music.stream.set_sync_stream_volume(2,-60)
	change_health(0,0)
	score_set.connect(increase_score)
	
	var y: ParallaxLayer #spawn stars:
	var star_scale: float
	for j in 2:
		if j==0: #determine layer and scale
			y=back_layer
			star_scale=0.5
		if j==1: 
			y=mid_layer
			star_scale=1
		if j==2:
			y=front_layer
			star_scale=3
		for i in 50: #add stars in said layer
			add_star(y, star_scale)

func add_star(x: ParallaxLayer, star_scale: float):
	var instance = STAR.instantiate()
	instance.position=Vector2(randi_range(-100,1200),randi_range(-100,640))
	instance.scale = Vector2(star_scale, star_scale)
	x.add_child(instance)

func _process(delta: float) -> void:
	camera.position=get_viewport_rect().size/Vector2(2,2)+(Vector2(player.position.x,player.position.y*2)-(Vector2(576,192.0*3)))*0.5
	planet.rotation+=0.003

func _on_boulder_spawn_timeout() -> void:
	var instance = BOULDER.instantiate()
	var dist := randf_range(-20,20)
	
	instance.global_position = Vector2(
		sin(dist)*RADIUS,
		cos(dist)*RADIUS
	) + Vector2(576,320)
	
	instance.time_scale=timeScale
	instance.destination=planet.global_position
	
	add_child(instance)

func change_health(player_change: int, planet_change: int) -> void:
	playerHealth+=player_change
	planetHealth+=planet_change
	player_health_text.text="PLAYER HEALTH: " + str(playerHealth) + "/3"
	planet_health_text.text="PLANET HEALTH: " + str(planetHealth) + "/3"
	if playerHealth==0 || planetHealth==0:
		get_tree().reload_current_scene()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	change_health(-1,0)

func _on_planet_hurt_area_entered(area: Area2D) -> void:
	change_health(0,-1)
	timeScale-=0.1
	if timeScale<1.0:
		timeScale=1.0
	if timeScale==1.0:
		boulder_spawn.wait_time=DEF_BOULDER_SPAWN_TIME
	if timeScale<1.25: update_combo(0)
	if timeScale<1.4: update_combo(1)


func _on_time_increase_timeout() -> void:
	boulder_spawn.wait_time=DEF_BOULDER_SPAWN_TIME/(timeScale*1.5)
	if timeScale<1.4:
		timeScale+=0.05
	if timeScale>=1.25:
		update_combo(1)
	if timeScale>=1.4:
		update_combo(2)

func update_combo(combo: int) -> void:
	match combo:
		0:
			music.stream.set_sync_stream_volume(1,-60)
			music.stream.set_sync_stream_volume(2,-60)
			combo_set=1
			combo_text.text="[center]COMBO: 1X[/center]"
		1:
			music.stream.set_sync_stream_volume(1,0)
			music.stream.set_sync_stream_volume(2,-60)
			combo_text.text="[center]COMBO: 2X[/center]"
			combo_set=2
		2:
			music.stream.set_sync_stream_volume(2,0)
			combo_text.text="[center]COMBO: 3X[/center]"
			combo_set=3

func increase_score() -> void:
	score+=(combo_set+1)
	score_text.text="[center]SCORE: " + str(score) + "[/center]"
