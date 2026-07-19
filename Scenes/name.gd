extends Control

@onready var sound: AudioStreamPlayer2D = $Sound

func _ready() -> void:
	$LineEdit.grab_focus()
	$LineEdit.text_submitted.connect(_on_name_submitted)

func _on_name_submitted(player_name: String) -> void:
	await Talo.players.identify("username", player_name)
	await submit_score(get_current_score())
	get_tree().change_scene_to_file("res://Scenes/highscore.tscn")

func submit_score(score: int) -> void:
	sound.play()
	var res := await Talo.leaderboards.add_entry("high_scores", score)
	if res == null:
		print("Failed to submit score — check leaderboard name/access key scopes")
		return
	print("New high score: %s" % res.updated)

func get_current_score() -> int:
	return Global.score


func _on_line_edit_text_changed(new_text: String) -> void:
	sound.play()

func _process(delta):	
	if Input.is_action_just_pressed("Hit"):
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
