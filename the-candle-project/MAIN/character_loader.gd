extends Node

signal load_character

@export var character: CharacterBody2D
@export var sprite_node_name: String
func _on_load_character() -> void:
	var newnode = load("res://MAIN/CharacterSaves/CharacterSave1.tscn").instantiate()
	var sprite = character.get_node(sprite_node_name)
	
	#scale new sprite to size of old sprite*scale of character 
	newnode.scale = sprite.texture.get_size()*sprite.scale/(newnode.get_child(1).texture.get_size()*character.scale)
	
	#delete old sprite and add new one
	sprite.queue_free()
	character.add_child(newnode)
	
	queue_free() #delete character loader. His job is done!
