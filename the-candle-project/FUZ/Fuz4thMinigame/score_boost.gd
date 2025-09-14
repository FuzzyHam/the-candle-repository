extends Marker2D

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar

var time_left = 750
var boost_multiplier = 2.0
signal boost_end

func _ready() -> void:
	label.text = str(boost_multiplier) + "x"

func _physics_process(delta: float) -> void:
	progress_bar.value = time_left
	time_left -= 1
	if time_left <= 0:
		boost_end.emit(self)
		queue_free()
