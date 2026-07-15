extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@onready var bat_hitbox_right = $AnimationPlayer/BatRight
@onready var bat_hitbox_left = $AnimationPlayer/BatLeft
@onready var animationplayer = $AnimationPlayer 
@onready var player_sfx = $PlayerEffects
var is_hit : bool = false
var is_hit_right : bool = false
var is_hit_left : bool = false
var is_sfx : bool = false

#Audio Preloads
var jump_audio = preload("res://Audio/SFX/SFX_jump.wav")
var bar_swings = [
	preload("res://Audio/SFX/Bat_Swing1.wav"), 
	preload("res://Audio/SFX/Bat_Swing2.wav"),
	preload("res://Audio/SFX/Bat_Swing3.wav")]


func _ready() -> void:
	bat_hitbox_right.set_deferred("monitorable", false)
	bat_hitbox_left.set_deferred("monitorable", false)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		player_sfx.stream = jump_audio
		player_sfx.play()
		
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if !is_hit:
		animation_tree(direction)
		
	move_and_slide()

	if direction < 0:
		animationplayer.flip_h = true
		$EffectSprite2D.flip_h = true
		$EffectSprite2D.position.x = -16
	if direction > 0:
		animationplayer.flip_h = false
		$EffectSprite2D.flip_h = false
		$EffectSprite2D.position.x = 16
	if Input.is_action_just_pressed("Hit"):
		action_hit(animationplayer.flip_h)
	
	if Input.is_action_pressed("N"):
		N()
		is_hit = true
	
func action_hit(face) -> void:
	is_hit = true
	
	if !is_sfx:
		is_sfx = true
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = bar_swings[randf_range(0,2)]
		player.play()
		player.finished.connect(player.queue_free)
	if face:
		bat_hitbox_left.set_deferred("monitorable", true)
		is_hit_left = true
		
	else:
		bat_hitbox_right.set_deferred("monitorable", true)
		is_hit_right = true
		
	animationplayer.play("hit")
	$EffectSprite2D.play("hitR")

	
func animation_tree(direction) -> void:
	if direction:
		if is_on_floor():
			animationplayer.play("run")
		else:
			animationplayer.play("jump")
	else:
		if is_on_floor():
			animationplayer.play("stand")
		else:
			animationplayer.play("jump")
	pass

func _on_animation_player_animation_finished() -> void:
	if animationplayer.animation == "hit":
		is_hit = false
		is_hit_right = false
		is_hit_left = false
		is_sfx = false
		bat_hitbox_right.set_deferred("monitorable", false)
		bat_hitbox_left.set_deferred("monitorable", false)
	if animationplayer.animation == "n":
		is_hit = false

		
	pass # Replace with function body.

func N() -> void:
	animationplayer.play("n")
	
	
