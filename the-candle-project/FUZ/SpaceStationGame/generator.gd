extends Area2D

signal cool_generator
signal overheat

@onready var progress_bar: ProgressBar = $ProgressBar

var heating_up = false
var heat = 0
const HEAT_MAX = 1500

func _ready() -> void:
	progress_bar.max_value = HEAT_MAX

func _physics_process(delta: float) -> void:
	if heating_up:
		heat += 1
		progress_bar.value = heat
		if heat >= HEAT_MAX:
			overheat.emit()
			cool_down()

func heat_up():
	heating_up = true
	heat = 0
	progress_bar.visible = true
	progress_bar.value = heat
	
func cool_down():
	heating_up = false
	heat = 0
	progress_bar.visible = false
	progress_bar.value = heat

func _on_body_entered(body: Node2D) -> void:
	cool_down()
	cool_generator.emit()
