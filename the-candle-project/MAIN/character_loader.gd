extends Node

signal load_character

@export var character: CharacterBody2D

func _on_load_character() -> void:
	var newnode = load("res://MAIN/CharacterSaves/CharacterSave1.tscn").instantiate()
	
	#scale new sprite to size of old sprite*scale of character 
	newnode.scale = character.texture.get_size()/(newnode.get_child(1).texture.get_size()*character.scale)
	
	#delete old sprite and add new one
	character.texture=null
	character.add_child(newnode)
	
	queue_free() #delete character loader. His job is done!
