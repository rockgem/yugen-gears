extends Node


signal game_win


var currently_clicked_gear = null
var main_ref = null

var RPM = 6
var AM = 180 / PI
var rot = 0


func calculate_gears_data():
	for gear in main_ref.gears:
		var parent_id = int(gear.data['connection'])
		
		set_ratio(gear, parent_id)
		#set_rotation(gear, parent_id)


func get_gear_with_id(id: int):
	var gears = main_ref.gears
	var final_gear = null
	
	for gear in gears:
		if gear.data['id'] == id:
			final_gear = gear
			
			break
	
	return final_gear


func generate_gear_dimension(teeth_amount, P):
	var scale = 100
	var OD = (teeth_amount + 2)/P
	var RD = (teeth_amount - 2.3)/P
	
	var real_w = ceil(RD / 2 * scale) * 2
	
	return real_w


func set_ratio(self_gear, parent_id):
	var parent_gear = get_gear_with_id(parent_id)
	
	if parent_gear == null:
		return
	
	self_gear.data['ratio'] = parent_gear.data['n_teeth'] / self_gear.data['n_teeth']
	self_gear.data['total_ratio'] = parent_gear.data['total_ratio'] * self_gear.data['ratio']


func set_rotation(self_gear, parent_id):
	var parent_gear = get_gear_with_id(parent_id)
	
	var y_dif = -1 * (parent_gear.data['y'] - self_gear.data['y'])
	var x_dif = parent_gear.data['x'] - self_gear.data['x']
	
	var angle = rad_to_deg(atan2(y_dif, x_dif))
	var rot = 180 - ((parent_gear.data['rotation'] + angle) * self_gear.data['ratio']) - angle
	
	self_gear.data['angle'] = fix6(rot + angle)
	self_gear.data['joint_angle'] = angle


func calculate_angle(gear1: Vector2, gear2: Vector2):
	var x_diff = gear2.x - gear1.x
	var y_diff = -1 * (gear2.y - gear1.y)
	
	var angle = rad_to_deg(atan2(y_diff, x_diff))
	
	return angle


func fix6(v):
	return round( 10000000 * v ) / 10000000


func fix2(v):
	return round(100 * v) / 100
