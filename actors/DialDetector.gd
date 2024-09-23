extends Area2D

signal area_touched


func _on_area_entered(area: Area2D) -> void:
	if ManagerGame.currently_clicked_gear_teeth:
		if ManagerGame.currently_clicked_gear_teeth.get_node('Area2D') == area:
			ManagerGame.currently_clicked_gear_teeth.parent_gear.is_rotating = false
			ManagerGame.currently_clicked_gear = null
			
			ManagerGame.currently_clicked_gear_teeth.highlight(false)
			
			get_tree().get_nodes_in_group("Cannon")[0].shoot()
			
			print('hoy yawa')
			
			area_touched.emit()


func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
