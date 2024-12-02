extends Button
@onready var combined_sprites: Node2D = $"../../CombinedSprites"

@export var dir:bool
@export var category:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	combined_sprites.sprite_change.emit(dir,category)
