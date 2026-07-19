extends ProgressBar

func _ready():
	max_value = 100
	value = 0

func _process(delta):
	value += 20 * delta
	if value >= max_value:
		get_tree().change_scene_to_file("res://main/main.tscn")
