extends CharacterBody2D
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var SLIDE_SPEED = 500.0
@export var HURT_GRAVITY_MULTIPLIER = 2.0
@export var HURT_KNOCKBACK_FORCE = 300.0
@export var HURT_KNOCKBACK_UPWARD_BIAS = -0.3
@onready var bat_hitbox_right = $BatRight
@onready var bat_hitbox_left = $BatLeft
@onready var slide_hitbox_right = $SlideRight
@onready var slide_hitbox_left = $SlideLeft
@onready var animationplayer = $AnimationPlayer 
@onready var player_sfx = $PlayerEffects

@onready var Entity = preload("res://Scenes/slideeffect.tscn")

var is_game_over = false
var is_hit : bool = false
var is_hit_right : bool = false
var is_hit_left : bool = false
var is_sfx : bool = false
var is_sliding : bool = false
var is_hurt : bool = false
var SPEED2 = 300.0
#Audio Preloads
var jump_audio = preload("res://Audio/SFX/SFX_jump.wav")
var bar_swings = [
	preload("res://Audio/SFX/Bat_Swing1.wav"), 
	preload("res://Audio/SFX/Bat_Swing2.wav"),
	preload("res://Audio/SFX/Bat_Swing3.wav")]
func _ready() -> void:
	pass
	#bat_hitbox_right.set_deferred("monitorable", false)
	#bat_hitbox_left.set_deferred("monitorable", false)
func _physics_process(delta: float) -> void:
	if is_game_over:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	if not is_on_floor():
		var gravity_this_frame = get_gravity() * delta
		if is_hurt:
			gravity_this_frame *= HURT_GRAVITY_MULTIPLIER
		velocity += gravity_this_frame
	elif is_hurt:
		is_hurt = false
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		player_sfx.stream = jump_audio
		player_sfx.play()
	if Input.is_action_just_pressed("Slide") and is_on_floor() and !is_sliding and !is_hit:
		action_slide(animationplayer.flip_h)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if is_sliding:
		var slide_dir := -1.0 if animationplayer.flip_h else 1.0
		velocity.x = slide_dir * SLIDE_SPEED
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED2)
	if !is_hit and !is_sliding and !is_hurt:
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
		is_hit_left = true
	else:
		is_hit_right = true
		
	animationplayer.play("hit")
	$EffectSprite2D.play("hitR")
	
func action_slide_hit(face) -> void:
	if face:
		is_hit_left = true
		
	else:
		is_hit_right = true


func action_slide(face: bool) -> void:
	is_sliding = true
	var dir := -1.0 if face else 1.0
	velocity.x = dir * SLIDE_SPEED
	animationplayer.play("slide")
	
	var instance = Entity.instantiate()
	get_parent().add_child(instance)
	instance.position = position
	
	if face:
		is_hit_left = true
		instance.get_node("AnimatedSprite2D").flip_h = true
	else:
		is_hit_right = true
		instance.get_node("AnimatedSprite2D").flip_h = false
	
	instance.start()
	action_slide_hit(face)
	
func take_hit(source_position: Vector2) -> void:
	if is_on_floor():
		return  
	if is_hurt:
		return
	is_hurt = true
	animationplayer.play("hurt")
	var knock_dir = (global_position - source_position).normalized()
	knock_dir.y += HURT_KNOCKBACK_UPWARD_BIAS
	knock_dir = knock_dir.normalized()
	velocity = knock_dir * HURT_KNOCKBACK_FORCE
	
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
		#at_hitbox_right.set_deferred("monitorable", false)
		#t_hitbox_left.set_deferred("monitorable", false)
	if animationplayer.animation == "n":
		is_hit = false
	if animationplayer.animation == "slide":
		is_sliding = false
		is_hit_right = false
		is_hit_left = false
	if animationplayer.animation == "hurt" and !is_hurt:
		animation_tree(Input.get_axis("Left", "Right"))
func N() -> void:
	animationplayer.play("n")
func game_over() -> void:
	is_game_over = true
	animationplayer.play("gameover")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	get_tree().call_group("island", "player_fell")
