extends AnimatableBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var nitro_radius: Area2D = $NitroRadius


var block_type = "STONE"
var ore_type = "TOPAZ"
var at_bottom = false
var old_chunk = false
var ray_cast_is_ready = false
var nitro_activated = false

var lava_drip_time = 100
