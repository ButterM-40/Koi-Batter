extends Node2D

@export var Entity : PackedScene
@export var spawn_interval: float = 2.0      # "length" — time between spawns

@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D
@onready var spawn_timer: Timer = $Timer


func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	if not spawn_timer.timeout.is_connected(_on_timer_timeout):
		spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()

func _on_timer_timeout() -> void:
	spawn_entity()
func spawn_entity() -> void:
	var instance = Entity.instantiate()
	var shape: RectangleShape2D = spawn_area.shape
	var half_size = shape.size / 2.0

	var random_x = randf_range(-half_size.x, half_size.x)
	var random_y = randf_range(-half_size.y, half_size.y)

	instance.position = global_position + spawn_area.position + Vector2(random_x, random_y)

	get_tree().current_scene.add_child(instance)
