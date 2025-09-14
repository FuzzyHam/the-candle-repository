extends Node2D

@onready var sprite: Sprite2D = $Sprite
const STAR_1 = preload("res://AG/AGMinigame2/star1.png")
const STAR_2 = preload("res://AG/AGMinigame2/star2.png")
const STAR_3 = preload("res://AG/AGMinigame2/star3.png")
const STAR_4 = preload("res://AG/AGMinigame2/star4.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random := randi_range(0,3)
	match random:
		0:
			sprite.texture=STAR_1
		1:
			sprite.texture=STAR_2
		2:
			sprite.texture=STAR_3
		3:
			sprite.texture=STAR_4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
