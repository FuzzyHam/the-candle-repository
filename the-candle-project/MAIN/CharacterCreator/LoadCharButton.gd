extends Button

@export var character_body_2d: CharacterBody2D
@export var sprite_2d: Sprite2D
@onready var character_loader: Node = $"../CharacterLoader"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	character_loader.load_character.emit()
	queue_free()
