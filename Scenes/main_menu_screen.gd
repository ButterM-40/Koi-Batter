extends Node2D


@onready var Option : int = 0

func _ready():
	$StartGame.visible = true
	$Scoreboard.visible = false
	$Exit.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("Jump"):
		if Option == 0:
			Option =2
		else:
			Option -=1	
	if Input.is_action_just_pressed("Down"):
		if Option == 2:
			Option =0
		else:
			Option +=1	
	
	if Input.is_action_just_pressed("Hit"):
		if Option == 0:
			get_tree().change_scene_to_file("res://Scenes/Game.tscn")
		if Option == 1:
			#get_tree().change_scene_to_file("???")
			pass
		if Option == 2:
			get_tree().quit()
	
	if Option == 0:
		$StartGame.visible = true
		$Scoreboard.visible = false
		$Exit.visible = false
	if Option == 1:
		$StartGame.visible = false
		$Scoreboard.visible = true
		$Exit.visible = false
	if Option == 2:
		$StartGame.visible = false
		$Scoreboard.visible = false
		$Exit.visible = true
