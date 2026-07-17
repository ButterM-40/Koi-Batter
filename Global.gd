extends Node

signal score_changed(new_score: int)
var score: int = 0

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	
func get_score() -> int:
	return score
