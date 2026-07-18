extends Node2D

@export var fish_animated: AnimatedSprite2D 
@export var effect_animated: AnimationPlayer
@export var move_speed: float = 100.0
@export var wave_frequency: float = 2.0
@export var wave_amplitude: float = 100.0
@export var gravity: float = 100.0
@export var fall_velocity: float = 0.0
@onready var JumpTimer : Timer = $JumpTimer
@export var knockback_force: float = 400.0
@export var knockback_upward_bias: float = -0.3
@onready var Hitbox : Area2D = $AnimatedSprite2D/Area2D

var hits_taken: int = 0
var rotation_speed: float = 0.0
var start_x: float = 0.0
var time_elapsed: float = 0.0
var is_moving: bool = false
var is_falling: bool = false
var is_rising: bool = false
var knock_vel: Vector2 = Vector2.ZERO
var is_knocked: bool = false
var imin: bool = false
var is_hit: bool = false

var hit_normal = preload("res://Audio/SFX/SFX_hit.wav")
var hit_success = preload("res://Audio/SFX/SFX_hitSuccess.wav")
var fish_variant : int = 0

func _ready() -> void:
	fish_variant = randi_range(0,3)
	start_x = position.x
	Hitbox.set_deferred("monitoring", false)
	z_index = -200
	_fish_spawning()

func _fish_spawning() -> void:
	fish_animated.play("appear" + str(fish_variant))
	effect_animated.play("fade")
	is_moving = true
	JumpTimer.start()
	
func _process(delta: float) -> void:
	if is_moving:		
		time_elapsed += delta   # advance time so sin() actually changes
		position.x = start_x + sin(time_elapsed * wave_frequency) * wave_amplitude
		position.y += move_speed * delta
	if is_rising:
		position.y -= move_speed * delta
	elif is_falling and !is_knocked:
		action_falling(delta)
	if is_knocked:
		knock_vel.y += gravity * delta  # gravity still pulls it back down
		position += knock_vel * delta
		if fish_variant != 2:
			rotation += rotation_speed * delta
	if Hitbox.monitoring:
		_check_bat_hit()

func _check_bat_hit() -> void:
	for area in Hitbox.get_overlapping_areas():
		if not area.is_in_group("bat"):
			continue
		var player = area.get_parent()
		if (area == player.bat_hitbox_right and player.is_hit_right) \
		or (area == player.bat_hitbox_left and player.is_hit_left):
			_on_hit_by_bat(area)
			break

func _on_jump_timer_timeout() -> void:
	is_moving = false
	fish_animated.play("fish_jump" + str(fish_variant))

func _on_animated_sprite_2d_animation_finished() -> void:
	imin = true
	z_index = -1
	if fish_animated.animation == ("fish_jump" + str(fish_variant)) and !is_knocked:
		Hitbox.set_deferred("monitoring", true)
		is_falling = true
		rotation_speed = randf_range(-2.0, 2.0)
		fish_animated.flip_h = randf() < 0.5

func action_falling(delta: float) -> void:
	if imin == false:
		fish_animated.play("fish_jump" + str(fish_variant))
	if imin == true:
		fish_animated.play("default" + str(fish_variant))
	fall_velocity += gravity * delta
	if fish_variant == 2:
		fall_velocity += gravity * 1.5 * delta
	position.y += fall_velocity * delta
	if fish_variant != 2:
		rotation += rotation_speed * delta

func _on_hit_by_bat(bat: Area2D) -> void:
	if is_hit:
		return
	is_hit = true

	fish_animated.play("fish_hit" + str(fish_variant))

	if fish_variant == 0 and hits_taken == 0:
		hits_taken = 1
		is_knocked = false
		knock_vel = Vector2.ZERO
		is_falling = false
		is_rising = true
		Global.add_score(30)

		await get_tree().create_timer(2.0).timeout
		is_rising = false
		fall_velocity = 0.0  
		is_falling = true
		
		await get_tree().create_timer(0.3).timeout
		is_hit = false
		return

	var hit_direction: Vector2 = (global_position - bat.global_position).normalized()
	hit_direction.y += knockback_upward_bias
	hit_direction = hit_direction.normalized()
	knock_vel = hit_direction * knockback_force
	rotation_speed = randf_range(-2.0, 2.0)
	is_knocked = true

	if fish_variant == 2:
		Global.add_score(20)
	else:
		Global.add_score(10)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
