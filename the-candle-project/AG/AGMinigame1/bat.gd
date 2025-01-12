extends CharacterBody2D

@onready var bat_move: Timer = $BatMove
@export var canHurt:bool = true
const CAUTION = preload("res://AG/AGMinigame1/caution.tscn")

func _ready() -> void:
	get_parent().wave_start.connect(_on_wave_start)

func _physics_process(delta: float) -> void:
	if get_parent().waveInProgress==false:
		canHurt=false
		bat_move.paused=true
		self.visible=false

func _on_bat_move_timeout() -> void:
	var tween:Tween = self.create_tween()
	var newPos:Vector2 = Vector2(randi_range(192,952),randi_range(64,584))
	tween.tween_property(self, "global_position",newPos,bat_move.wait_time)

func _on_wave_start() -> void:
	get_parent().bat_spawn.emit()
	queue_free()
