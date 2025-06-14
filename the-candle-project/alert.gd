extends Marker2D

var life_span
var time_left
var side
signal alert_timeout
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	time_left = life_span

func _physics_process(delta: float) -> void:
	time_left -= 1
	if time_left <= life_span/3:
		animated_sprite.speed_scale = 2
	if time_left <= 0:
		alert_timeout.emit(self)
		queue_free()
	
