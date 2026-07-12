extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@export var animation_player : AnimatedSprite2D

@onready var animationplayer = $AnimationPlayer 


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("Hit"):
		action_hit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			animationplayer.play("run")
		else:
			animationplayer.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animationplayer.play("stand")
		else:
			animationplayer.play("jump")

	move_and_slide()

	if direction < 0:
		animationplayer.flip_h = true
	if direction > 0:
		animationplayer.flip_h = false
	
func action_hit() -> void:
	animationplayer.play("hit")
	
