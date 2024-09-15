extends Node2D


var data = {}

var gear_rotation_direction = 1

var is_rotating = false

func _ready() -> void:
	if data:
		$Sprite2D.texture = load('res://art/g_%s.png' % str(data['n_teeth']))
		global_position.x = data['x']
		global_position.y = data['y']
		rotation_degrees = data['angle']
		
		var new_shape = CircleShape2D.new()
		new_shape.radius = data['container_dims'] / 2 + 26
		$Area2D/CollisionShape2D.shape = new_shape
		
		if data.has('dot'):
			for gear_data in data['dot']:
				var dot = load("res://actors/Dot.tscn").instantiate()
				dot.get_node('Sprite2D').position.x = data['container_dims'] / 2 + 4.0
				dot.get_node('Sprite2D').position.y += gear_data['offset']
				
				dot.rotation_degrees = (360 / data['n_teeth']) * gear_data['teeth_index']
				
				match gear_data['color']:
					'green':
						dot.rotation_degrees += rotation_degrees
						dot.get_node('Sprite2D').texture = load("res://art/dot_green.png")
						
						ManagerGame.main_ref.spawn_obj(dot, global_position)
					'blue':
						add_child(dot)


func _physics_process(delta: float) -> void:
	if is_rotating:
		var connected_gears = $Area2D.get_overlapping_areas()
		
		rotation_degrees += data['speed'] * gear_rotation_direction
		
		for gear in connected_gears:
			gear.get_parent().chain_rotate(gear_rotation_direction, null)


func _unhandled_input(event: InputEvent) -> void:
	if data['is_rotatable'] == false:
		return
	
	if event is InputEventScreenTouch and event.pressed:
		if $Sprite2D.is_pixel_opaque(to_local(event.position)):
			gear_rotation_direction = 1
			
			ManagerGame.currently_clicked_gear = self
			
			is_rotating = true
	
	if event is InputEventScreenTouch and !event.pressed and is_rotating:
		if $Sprite2D.is_pixel_opaque(to_local(event.position)):
			is_rotating = false
			
			var connected_gears = $Area2D.get_overlapping_areas()
			for gear in connected_gears:
				gear.get_parent().chain_stop(null)
			
			ManagerGame.currently_clicked_gear = null


func chain_rotate(inital_rotation, parent):
	gear_rotation_direction = -inital_rotation
	
	var connected_gears = $Area2D.get_overlapping_areas()
	
	rotation_degrees += data['speed'] * gear_rotation_direction
	
	for gear in connected_gears:
		if gear.get_parent() == ManagerGame.currently_clicked_gear or gear.get_parent() == self:
			continue
		if gear.get_parent() == parent:
			continue
		
		gear.get_parent().chain_rotate(gear_rotation_direction, self)


func chain_stop(parent):
	is_rotating = false
	
	var connected_gears = $Area2D.get_overlapping_areas()
	
	for gear in connected_gears:
		if gear.get_parent() == ManagerGame.currently_clicked_gear or gear.get_parent() == self:
			continue
		if gear.get_parent() == parent:
			continue
		
		gear.get_parent().chain_stop(self)
