extends Node2D

var gears = []



func _ready() -> void:
	ManagerGame.main_ref = self
	
	var gears_data = get_data("res://reso/gear_input.json")
	
	var g = load("res://actors/Gear.tscn")
	
	var count = 0
	for gear in gears_data:
		var ng = g.instantiate()
		ng.data.merge(gears_data[gear])
		ng.data['id'] = count
		
		gears.append(ng)
		
		count += 1
	
	ManagerGame.calculate_gears_data()
	
	for gear in gears:
		add_child(gear)
	
	calculate_rotations()


func _physics_process(delta: float) -> void:
	var all_dots_in = true
	for dot in get_tree().get_nodes_in_group('Dot'):
		if dot.has_dot == false:
			all_dots_in = false
			break
	
	if all_dots_in:
		ManagerGame.game_win.emit()


func get_data(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	
	return j.data


func spawn_obj(instance, g_pos):
	instance.global_position = g_pos
	
	add_child(instance)


func calculate_rotations():
	for gear in gears:
		if gear.data['connection'] == 0:
			continue
		
		var parent_gear= null
		for gr in gears:
			if gr.data['id'] == gear.data['connection']:
				parent_gear = gr
				break
		
		if parent_gear == null:
			continue
		
		var parent_teeth = parent_gear.data['n_teeth']
		var child_teeth = gear.data['n_teeth']
		var tooth_pitch_angle = 360.0 / parent_teeth
		var rotation_angle = tooth_pitch_angle * (child_teeth / parent_teeth)
		
		var angle_between = gear.global_position.angle_to(parent_gear.global_position)
		
		gear.rotation_degrees += rotation_angle
