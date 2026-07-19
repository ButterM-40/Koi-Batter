extends Node2D

func _unhandled_input(event):
	if event is InputEventKey || event is InputEventJoypadButton:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
