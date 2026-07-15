extends StaticBody2D
@onready var floor_stage : Area2D = $FloorDetection
@export var StringsStage : Node
@onready var string_children_count : int = 0

func _ready() -> void:
	string_children_count = StringsStage.get_child_count()

func _on_floor_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("fish"):
		var available = StringsStage.get_children().filter(func(c): return not c.has_broken)
		print(available.size())
		if available.size() > 0:
			var target = available[randi_range(0, available.size() - 1)]
			target._break()
