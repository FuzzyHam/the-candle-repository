extends Button

@export var character_body_2d: CharacterBody2D
@export var sprite_2d: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	var newnode = load("res://MAIN/CharacterSaves/CharacterSave1.tscn").instantiate()
	newnode.scale = sprite_2d.texture.get_size()/(newnode.get_child(1).texture.get_size()*character_body_2d.scale)
	sprite_2d.queue_free()
	character_body_2d.add_child(newnode)
	queue_free()
