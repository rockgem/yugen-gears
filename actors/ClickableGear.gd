extends Node2D

signal clicked

var parent_gear = null


func highlight(turn_on = true):
	if turn_on:
		$Area2D/Sprite2D.modulate = Color.GREEN
	else:
		$Area2D/Sprite2D.modulate = Color.WHITE


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch and !event.pressed:
		if parent_gear:
			highlight()
			
			ManagerGame.currently_clicked_gear = parent_gear
			parent_gear.is_rotating = true
			
			ManagerGame.currently_clicked_gear_teeth = self
			
			clicked.emit()
