extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var speed = 1500.0

func _ready() -> void:
	global_position=Vector2(randi_range(224,916),1400)
	var the_scale=randf_range(0.3,0.8)
	self.scale = Vector2(the_scale,the_scale*randf_range(1.3,1.6))
	if self.scale.x>=0.6: 
		self.scale=self.scale*Vector2(1.5,1.5)*Vector2(0.5,3)
		self.z_index=1
		sprite_2d.self_modulate.a=(randf_range(0.13,0.2)*the_scale)*2
		speed=speed*(the_scale*the_scale)*1.6
	else: 
		self.z_index=-1
		sprite_2d.self_modulate.a=(the_scale*0.1)
		speed=speed*(the_scale*the_scale)*1.3

func _physics_process(delta: float) -> void:
	self.global_position.y-=speed*delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
