extends Node2D

var hflip : int

func _ready():
	if hflip == 1:
		$AnimatedSprite2D.flip_h = true

func _on_animated_sprite_2d_animation_finished():
	queue_free()
	
