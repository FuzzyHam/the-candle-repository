extends Node2D

signal sprite_change(dir:bool,target:String)

@onready var skin: Sprite2D = $Skin
@onready var mouth: Sprite2D = $Mouth
@onready var nose: Sprite2D = $Nose
@onready var eyes: Sprite2D = $Eyes
@onready var eyebrows: Sprite2D = $Eyebrows
@onready var hair: Sprite2D = $Hair
@onready var accessory: Sprite2D = $Accessory
@onready var shape: Sprite2D = $Shape

var mouth_num:int = 0
var max_mouth:int = 14

var shape_num:int = 0
var max_shape:int = 2

var nose_num:int = 0
var max_nose:int = 6

var eyes_num:int = 0
var max_eyes:int = 10

var eyebrows_num:int=0
var max_eyebrows:int=3

var hair_num:int = 0
var max_hair:int = 2

var accessory_num:int = 0
var max_accessory:int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 7:
		get_child(i).set_owner(self)

func _on_sprite_change(dir: bool, target: String) -> void:
	match target:
		"Mouth":
			if dir:
				mouth_num+=1
			else:
				mouth_num-=1
			if mouth_num>max_mouth: mouth_num=0
			if mouth_num<0: mouth_num=max_mouth
			if mouth_num>0:
				mouth.texture=load("res://MAIN/CharacterCreator/Mouth"+str(mouth_num)+".png")
			else: mouth.texture=null
		"Shape":
			if dir:
				shape_num+=1
			else:
				shape_num-=1
			if shape_num>max_shape: shape_num=0
			if shape_num<0: shape_num=max_shape
			shape.texture=load("res://MAIN/CharacterCreator/Shape"+str(shape_num+1)+".png")
			if shape_num==2: skin.hide()
			else: skin.show()
		"Nose":
			if dir:
				nose_num+=1
			else:
				nose_num-=1
			if nose_num>max_nose: nose_num=0
			if nose_num<0: nose_num=max_nose
			if nose_num>0:
				nose.texture=load("res://MAIN/CharacterCreator/Nose"+str(nose_num)+".png")
			else: nose.texture=null
		"Eyes":
			if dir:
				eyes_num+=1
			else:
				eyes_num-=1
			if eyes_num>max_eyes: eyes_num=0
			if eyes_num<0: eyes_num=max_eyes
			if eyes_num>0:
				eyes.texture=load("res://MAIN/CharacterCreator/Eyes"+str(eyes_num)+".png")
			else: eyes.texture=null
		"Eyebrows":
			if dir:
				eyebrows_num+=1
			else:
				eyebrows_num-=1
			if eyebrows_num>max_eyebrows: eyebrows_num=0
			if eyebrows_num<0: eyebrows_num=max_eyebrows
			if eyebrows_num>0:
				eyebrows.texture=load("res://MAIN/CharacterCreator/Eyebrows"+str(eyebrows_num)+".png")
			else: eyebrows.texture=null
		"Hair":
			if dir:
				hair_num+=1
			else:
				hair_num-=1
			if hair_num>max_hair: hair_num=0
			if hair_num<0: hair_num=max_hair
			if hair_num>0:
				hair.texture=load("res://MAIN/CharacterCreator/Hair"+str(hair_num)+".png")
			else: hair.texture=null
		"Accessory":
			if dir:
				accessory_num+=1
			else:
				accessory_num-=1
			if accessory_num>max_accessory: accessory_num=0
			if accessory_num<0: accessory_num=max_accessory
			if accessory_num>0:
				accessory.texture=load("res://MAIN/CharacterCreator/Accessory"+str(accessory_num)+".png")
			else: accessory.texture=null
