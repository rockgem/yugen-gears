extends Node2D

var gears = []

func _ready() -> void:
	ManagerGame.main_ref = self
	
	ManagerGame.generate_imgs_and_data(ManagerGame.json_path_current)
	
	for gear in ManagerGame.final_json:
		var g = load("res://actors/Gear.tscn").instantiate()
		g.data = ManagerGame.final_json[gear]
		
		add_child(g)
	
	if ManagerGame.current_game_mode == ManagerGame.GAME_MODE.SHOOTING:
		var f = FileAccess.open(ManagerGame.json_path_current, FileAccess.READ)
		var j = JSON.new()
		j.parse(f.get_as_text())
		
		var orig_data = j.data
		
		if orig_data.has('target'):
			var target = load("res://actors/Target.tscn").instantiate()
			
			target.global_position.x = orig_data['target']['x']
			target.global_position.y = orig_data['target']['y']
			
			add_child(target)


func _physics_process(delta: float) -> void:
	if ManagerGame.current_game_mode == ManagerGame.GAME_MODE.DOTS:
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
