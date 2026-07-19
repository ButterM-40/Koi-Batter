extends StaticBody2D
@onready var floor_stage : Area2D = $FloorDetection
@onready var floor_anim : AnimatedSprite2D = $FloorDetection/AnimatedSprite2D
@export var StringsStage : Node
@onready var string_children_count : int = 0
var is_ending = false

func _ready() -> void:
	floor_anim.play("none")
	string_children_count = StringsStage.get_child_count()

func _on_floor_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("fish"):
		var fish_node = area.owner
		if fish_node and fish_node.is_hit:
			return
		var available = StringsStage.get_children().filter(func(c): return not c.has_broken)
		
		if available.size() > 0:
			var local_x = floor_anim.get_parent().to_local(area.global_position).x
			floor_anim.position.x = local_x
			floor_anim.play("default")
			var target = available[randi_range(0, available.size() - 1)]
			target._break()
			$AnimationPlayer.play("shakingIsland")
		if available.size() == 0:
			trigger_game_over()

func player_fell() -> void:
	var available = StringsStage.get_children().filter(func(c): return not c.has_broken)
	for target in available:
		target._break()
	is_ending = true
	$AnimationPlayer.play("shakingIsland")
	trigger_game_over()

func trigger_game_over() -> void:
	$"../CanvasLayer/RichTextLabel".visible=false
	$"../CanvasLayer/GameOver".visible = true
	$"../CanvasLayer/YourScore".visible = true
	$"../CanvasLayer/EndScore".visible = true
	$AnimationPlayer.play("sinkingIsland")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "sinkingIsland":
		get_tree().change_scene_to_file("res://Scenes/enter_name.tscn")
