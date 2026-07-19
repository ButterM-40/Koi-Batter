extends Control

@onready var entries := $Entries
var row_scene := preload("res://Scenes/row.tscn")
@onready var sound: AudioStreamPlayer2D = $Sound
func _ready() -> void:
	show_leaderboard()

func show_leaderboard() -> void:
	var res := await Talo.leaderboards.get_entries("high_scores")
	var top_entries := res.entries.slice(0, 10)
	var target_rows := 10

	for child in entries.get_children():
		child.queue_free()

	for i in range(target_rows):
		var row := row_scene.instantiate()
		if i < top_entries.size():
			var entry: TaloLeaderboardEntry = top_entries[i]
			row.get_node("Rank").text = str(i + 1)
			row.get_node("Name").text = entry.player_alias.display_name
			row.get_node("Score").text = str(int(entry.score))
		else:
			row.get_node("Rank").text = str(i + 1)
			row.get_node("Name").text = "---"
			row.get_node("Score").text = "-"
		entries.add_child(row)
		
func _physics_process(delta: float) -> void:
	sound.play()
	if Input.is_action_just_pressed("Enter"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
