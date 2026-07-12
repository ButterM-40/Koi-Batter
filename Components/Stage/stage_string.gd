extends Node2D

@onready var AnimationP = $AnimatedSprite2D
@onready var rando = 0

func _ready() -> void:
	rando = randi_range(0, 9)
	AnimationP.set_frame_and_progress(rando, rando)
