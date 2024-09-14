extends CanvasLayer


func _ready() -> void:
	ManagerGame.game_win.connect(on_game_win)


func on_game_win():
	get_tree().paused = true
	
	$GameOverPanel.show()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
