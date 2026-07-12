extends Node2D

@export var fish_animated: AnimatedSprite2D 
@export var effect_animated: AnimationPlayer
@export var move_speed: float = 100.0
@export var move_direction: Vector2 = Vector2.DOWN  
@export var wave_frequency: float = 2.0
@export var wave_amplitude: float = 100.0
@export var gravity: float = 100.0
@export var fall_velocity: float = 0.0
@onready var JumpTimer : Timer = $JumpTimer
@export var knockback_force: float = 400.0
@export var knockback_upward_bias: float = -0.3
@onready var Hitbox : Area2D = $AnimatedSprite2D/Area2D
var rotation_speed: float = 0.0
var start_x: float = 0.0
var time_elapsed: float = 0.0
var is_moving: bool = false
var is_falling: bool = false
var knock_vel: Vector2 = Vector2.ZERO
var is_knocked: bool = false

func _ready() -> void:
	start_x = position.x
	Hitbox.set_deferred("monitoring", false)
	_fish_spawning()

func _fish_spawning() -> void:
	fish_animated.play("appear")
	effect_animated.play("fade")
	is_moving = true
	JumpTimer.start()
	
func _process(delta: float) -> void:
	if is_moving:
		time_elapsed += delta   # advance time so sin() actually changes
		position.x = start_x + sin(time_elapsed * wave_frequency) * wave_amplitude
		position.y += move_speed * delta
	if is_falling:
		action_falling(delta)
	if is_knocked:
		knock_vel.y += gravity * delta  # gravity still pulls it back down
		position += knock_vel * delta
		rotation += rotation_speed * delta
		#position += move_direction.normalized() * move_speed * delta
	

func _on_jump_timer_timeout() -> void:
	is_moving = false
	fish_animated.play("fish_jump")
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	if fish_animated.animation == "fish_jump":
		Hitbox.set_deferred("monitoring", true)
		is_falling = true
		rotation_speed = randf_range(-2.0, 2.0)
		fish_animated.flip_h = randf() < 0.5
	pass # Replace with function body.
	
func action_falling(delta: float) -> void:
	fish_animated.play("default")
	fall_velocity += gravity * delta
	position.y += fall_velocity * delta
	rotation += rotation_speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bat"):
		_on_hit_by_bat(area)
	if area.is_in_group("Player"):
		pass
	if area.is_in_group("Stage"):
		pass
	pass

func _on_hit_by_bat(bat: Area2D) -> void:
	fish_animated.play("fish_hit")
	is_falling = false
	var hit_direction: Vector2 = (global_position - bat.global_position).normalized()
	hit_direction.y += knockback_upward_bias
	hit_direction = hit_direction.normalized()
	
	knock_vel = hit_direction * knockback_force
	is_knocked = true
