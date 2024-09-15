extends Node


signal game_win


var currently_clicked_gear = null
var main_ref = null

var AM = 180/PI
var RPM = 6
var gears = []
var rot = 0
var gears_data = []
var angles_dict = {}

var final_json = {}

func import_gears_from_file(file_path):
	#var file = open(file_path)
	#
	#var data = json.load(file)
	
	var file = FileAccess.open("res://reso/gear_input.json", FileAccess.READ)
	var j = JSON.new()
	j.parse(file.get_as_text())
	
	var data = j.data
	
	# iterate through the geard IDs
	for gear_id in range(len(data)):
		var gear_data = data[str(gear_id)]
	
		gears_data.append(gear_data)


func calculate_angles(gears):
	for gear_ind in range(len(gears_data)):
		if gears_data[gear_ind]['connection'] != -1:
			
			var curr_gear = gears[gear_ind]
			var parent_gear = gears[curr_gear['connection']]
			
			var gear1 = Vector2(parent_gear['x'], parent_gear['y'])
			var gear2 = Vector2(curr_gear['x'], curr_gear['y'])
			var y_diff = -1 * (gear2[1] - gear1[1])
			var x_diff = gear2[0] - gear1[0]
			var dist = sqrt(pow((gear2[0] - gear1[0]), 2) + pow((gear2[1] - gear1[1]), 2))
			
			var angle
			if dist == 0:
				angle = 0
			else:
				# angle = math.degrees(math.asin(y_diff/dist)) * math.degrees(math.acos(x_diff/dist))
				angle = rad_to_deg(atan2(y_diff, x_diff))
			
			angles_dict[str(gear_ind)] = angle
		else:
			angles_dict[str(gear_ind)] = 0


func converting_svgs_to_pngs(i):
	pass
	
	# for i in range(len(gears)):
	
	#with open(f'imgs/g_{i}.svg', 'a+') as f:
		#f.write(gears[i].svg)
	
	
	# converting from svg to png
	# for i in range(len(gears)):
	
	#cairosvg.svg2png(url=f'imgs/g_{i}.svg', write_to=f'imgs/g_{i}.png')
	#os.remove(os.getcwd() + f'\imgs\g_{i}.svg')

func update_json_file():
	var data = {}
	
	for i in gears.size():
		var new_gear = {}
		
		new_gear['x'] = gears_data[i]['x']
		new_gear['y'] = gears_data[i]['y']
		
		if gears[i].parentID != -1:
			pass
			#new_gear['x'] = gears[i].x
			#new_gear['y'] = gears[i].y
		else:
			new_gear['extra_x'] = gears[i].x
			new_gear['extra_y'] = gears[i].y
			
		new_gear['radius'] = gears_data[i]['radius']
		new_gear['n_teeth'] = gears_data[i]['n_teeth']
		new_gear['is_movable'] = gears_data[i]['is_movable']
		new_gear['is_rotatable'] = gears_data[i]['is_rotatable']
		new_gear['image'] = ''
		new_gear['connection'] = gears_data[i]['connection']
		new_gear['container_dims'] = gears[i].dim
		new_gear['angle'] = fix6(gears[i].rot + gears[i].baseangle)
		new_gear['speed'] = fix2(gears[i].totalratio * RPM) / 10
		#new_gear['width'] = gears_data[i]['w']
		
		data[str(i)] = new_gear
		
		if gears_data[i].has('dot'):
			data[str(i)].merge(gears_data[i])
	
	final_json = data


func polar_to_linear(p):
	var r = p['r']
	var a = p['a']
	
	a = (int((a + 360)) % 360) / AM
	var x = cos( a ) * r
	var y = -sin( a ) * r
	
	return {'x': x, 'y': y}


func linear_to_polar(c):
	var x = c['x']
	var y = c['y']
	
	var r = sqrt(x*x + y*y)
	var a = asin( y/r ) * AM
	
	if x < 0:   a = 180 - a
	a = int((a + 360)) % 360
	
	return {'r': r, 'a': a}


func fix6(v):
	return round( 10000000 * v ) / 10000000


func fix2(v):
	return round(100 * v) / 100


func pt(r, a):
	return {'r': r, 'a': a}


func create_svg_gear(N, D, P, ID, PA=27):
	var scale = 100
	var OD = (N + 2)/P
	var RD = (N - 2.3)/P
	var BC = D * cos(PA * PI/180)
	var CP = PI / P
	var rmin = RD / 2
	var rmax = OD / 2
	var rbase = BC / 2
	var pts = []
	var ac = 0
	var aca = 0
	var w = ceil( OD / 2 * scale) * 2
	var h = w
	
	var real_w = ceil(RD / 2 * scale) * 2
	
	var out = ''
	
	w = w + scale
	h = w
	
	#svg = f'<?xml version="1.0" encoding="utf-8"?><svg version="1.2" class="svggear" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="{w}px" height="{h}px" viewBox="{(-w/2)} {(-h/2)} {w} {h}" overflow="scroll" xml:space="preserve">'
	
	# calculate
	# first point
	pts.append(pt(rmin, 0))
	
	# loop variables
	var i = 1
	var pn = 0
	var step = 0.1
	var first = true
	var fix = 0
	while i < 100:
		# get a point
		var bpl = polar_to_linear( pt( rbase, -i) )       # base point linear
		var length = ((rbase * PI * 2) / 360) * i    # length
		var opl = polar_to_linear( pt( length, -i + 90) ) # add line
		var np = linear_to_polar( {'x': bpl['x'] + opl['x'], 'y': bpl['y'] + opl['y']} )
		
		if np['r'] >= rmin:
			if first:
				first = false
				step = (2/N) * 10
			
			if np['r'] < D / 2:
				ac = np['a']
				aca = i
			
			if np['r'] > rmax:
				fix += 1        # !!!!! atentie aici
				if fix < 10:
					i -= step
					step /= 2
					continue
				
				np['r'] = rmax
				pts.append(np)
				#add_pts( np )
				pn += 1
				break
				
			pts.append(np)
			pn += 1
			
		i += step
	
	# tukrozes
	var fa = 360 / N            # final a
	var ma = fa / 2 + 2 * ac    # mirror a
	var fpa = 0 if (fa - ma) > 0 else -(fa - ma) / 2    # first point a
	var m = len(pts)
	
	pts[0] = pt( rmin, fpa )    # fix first point a
	while pts[m - 1]['a'] > ma/2:
		pts.splice(m-1, 1)
		m -= 1
		pn -= 1
	
	i = pn
	while i >= 0:
		var bp = pts[i]
		var na = ma - bp['a']
		
		pts.append(pt( bp['r'], na ))
		
		i -= 1
	
	# repeat
	i = 1
	m = len(pts)
	while i < N:
		var p_ind = 0
		while p_ind < m:
			var bp = pts[p_ind]
			var na = bp['a'] + fa * i
			
			pts.append(pt( bp['r'], na ))
			
			p_ind += 1 
		
		i += 1
	
	
	# print points maybe
	#out += f'<path id="gearpoly{ID}" data-id="{ID}" class="gear" fill="#ddd" stroke="#444" stroke-width="1" stroke-miterlimit="10" d="M'
	
	var pts_index = 0
	while pts_index < len(pts):
		var point = polar_to_linear( pts[pts_index] )
		#out += str(fix6( point['x'] * scale )) + ',' + str(fix6( point['y'] * scale )) + ' '
		
		pts_index += 1
	
	#out += 'z"/>'
	
	
	# center cross
	#out += '<g class="guides"><polyline fill="none" stroke="#444" stroke-width="0.5" stroke-miterlimit="10" points="'
	#out += '10,0 -10,0"/>'
	#out += '<polyline fill="none" stroke="#444" stroke-width="0.5" stroke-miterlimit="10" points="'
	#out += '0,10 0,-10"/></g>'
	
	# first tooth marker
	# zpr = 1.57/P/4
	# zp = polar_to_linear( pt( D/2, ma/2 ) )
	# out += f'<circle fill="red" class="firstmarker" stroke="none" stroke-miterlimit="10" cx="{fix6(zp["x"]*scale)}" cy="{fix6(zp["y"]*scale)}" r="{fix6(zpr*scale)}"/>'
	
	
	#svg += out+'</svg>'
	
	# print(w)
	
	return {'svg': null,
			'dfx': null,
			'svgdata': '',
			'gearangle': fa,
			'baseangle': ac,
			'rsc': D * scale/2,
			'w': w,
			'h': h,
			'dim': real_w}


func rotate_gears(ID: int):
	#ID = ID or 0
	var gear = gears[ID]
	if ID == 0:
		gear.rot = rot - gear.jointangle
	else:
		var parentgear = gears[ gear.parentID ]
		
		if gear.axlejoint:
			gear.rot = parentgear.rot-gear.jointangle
		else:
			gear.rot = 180 - ((parentgear.rot + gear.jointangle) * gear.ratio) - gear.jointangle


func position_gears(ID: int, x, y):
	#self.ID = ID or 0
	var gear = gears[ID]
	var parentID = gear.parentID
	
	if parentID >= 0:
		var parentgear = gears[ parentID ]
		
		gear.ratio = parentgear.N / gears[ID].N
		
		var dist = parentgear.rsc + gear.rsc
		
		gear.offsetx = cos( gear.jointangle / AM) * dist
		gear.offsety = -sin( gear.jointangle / AM ) * dist
		
		gear.totalratio = parentgear.totalratio * gear.ratio
		
		gear.x = parentgear.x + gear.offsetx
		gear.y = parentgear.y + gear.offsety
	else:
		gear.x = x
		gear.y = y


func generate_imgs_and_data():
	import_gears_from_file('gear_input.json')
	
	calculate_angles(gears_data)
	
	for ind in range(len(gears_data)):
		
		var gear = gears_data[ind]
		
		var gear_data = create_svg_gear(gear['n_teeth'],
									float(gear['n_teeth']) / float(2 * float(gear['radius'])),
									float(2 * float(gear['radius'])), ind)
		
		var rsc = gear_data['rsc']
		var gearangle = gear_data['gearangle']
		var baseangle = gear_data['baseangle']
		var svg = gear_data['svg']
		var width = gear_data['w']
		var dim = gear_data['dim']

		# ang = -90

		# if gear['connection'] != -1:
		#     ang = angles_dict[str(ind)]

		gears.append(ModGear.new(
							gear['n_teeth'],
							float(2 * float(gear['radius'])),
							angles_dict[str(ind)],
							gear['connection'],
							gearangle,
							baseangle,
							rsc,
							svg,
							width,
							dim))
	
	for i in gears.size():
		position_gears(i, gears_data[i]['x'], gears_data[i]['y'])
		rotate_gears(i)
		
		converting_svgs_to_pngs(i)
	
	update_json_file()


func clear_datas():
	gears_data.clear()
	gears.clear()
	angles_dict.clear()
	final_json.clear()
