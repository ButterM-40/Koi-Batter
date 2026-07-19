extends Node2D

var hflip : int

func _ready():
	hflip = true
	if hflip == 1:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
func start():
	$AnimatedSprite2D.play("default")
func _on_animated_sprite_2d_animation_finished():
	queue_free()
	
