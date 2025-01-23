extends Node2D


func _physics_process(delta: float) -> void:
	var dif = global_position.direction_to(ManagerGame.main_ref.cannon_ref.global_position)
	
	global_position += dif * ManagerGame.config_data['target_speed'] * delta
	
	if global_position.distance_to(ManagerGame.main_ref.cannon_ref.global_position) < 5.0:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().queue_free()
	
	queue_free()
