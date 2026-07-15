extends Node2D

@onready var AnimationP = $AnimatedSprite2D
@onready var RingAnim = $AnimatedSprite2D2
@onready var rando = 0
@export var flip : bool = false
var has_broken: bool = false
var DefaultInt = 0

func _ready() -> void:
	
	rando = randi_range(0, 9)
	DefaultInt = randi_range(1, 2)
	
	AnimationP.set_frame_and_progress(rando, rando)
	RingAnim.flip_h = flip
	RingAnim.play("default" + str(DefaultInt))

func _break() -> void:
	RingAnim.play("break" + str(DefaultInt))
	pass

func _on_animated_sprite_2d_2_animation_finished() -> void:
	if AnimationP.animation != "nothing":
		AnimationP.play("rip")
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished() -> void:
	AnimationP.play("nothing")
	pass # Replace with function body.
