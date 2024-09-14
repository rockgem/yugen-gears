extends Node2D

var has_dot = false


func _ready() -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	has_dot = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	has_dot = false
