extends Control


func _on_dot_mode_pressed() -> void:
	ManagerGame.json_path_current = "res://reso/gear_input.json"
	ManagerGame.current_game_mode = ManagerGame.GAME_MODE.DOTS
	
	Sfx.play_sound('Click')
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_shoot_mode_pressed() -> void:
	ManagerGame.json_path_current = "res://reso/gear_input_shooting.json"
	ManagerGame.current_game_mode = ManagerGame.GAME_MODE.SHOOTING
	
	Sfx.play_sound('Click')
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
