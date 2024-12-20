extends Button

@onready var combined_sprites: Node2D = $"../../Positioner/CombinedSprites"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var scene = PackedScene.new()
	scene.pack(combined_sprites)
	ResourceSaver.save(scene, "res://MAIN//CharacterSaves//CharacterSave1.tscn")
