extends Node2D

var PanelScene = preload("res://scenes/Panel.tscn")

var row = 9
var col = 9

var size = 60
var font_size = 50

var offset = 4

var numbers = _create_multidim_array(row, col)
var panels = _create_multidim_array(row, col)


func _ready():
	_init_grid()
	_get_numbers()
	_get_panels()
	_show_numbers()
	_add_numbers()

func compare_array(arr1, arr2):
	var to_rtn = []
	for i in arr1:
		if !i in arr2:
			to_rtn.append(i)
	return to_rtn

func _add_numbers():
	for x in row:
		for y in col:
			if numbers[x][y] == 0:
				var candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]
				var current_row = _get_row(x)
				candidates = compare_array(candidates, current_row)
				var current_region = _get_region(x, y)
				candidates = compare_array(candidates, current_region)
				var current_col = _get_col(y)
				candidates = compare_array(candidates, current_col)
				var label : Label = panels[x][y].get_node("Label")
				numbers[x][y] = candidates.front()
				label.text = str(candidates.front())
			
			
		
#		for i in range(9):
#			var val = i+1
#			if !val in current_row:
#				candidates.append(val)
#		for y in col:
#			var current_col = _get_col(y)
#			for i in candidates:
#				if !i in current_col:
#			if numbers[x][y] == 0:
#				pass 
			

func _init_grid():
	var offset_x = 0
	var offset_y = offset
	
	for x in row:
		if x % 3 == 0:
			offset_y += offset
		offset_x = 0
		offset_y += offset
		for y in col:
			if y % 3 == 0:
				offset_x += offset
			offset_x += offset
			var panel = PanelScene.instance()
			panel.rect_size = Vector2(size, size)
			panel.rect_position = Vector2(size * y, size * x) + Vector2(offset_x, offset_y)
			add_child(panel)


func _get_numbers():
	for n in 3:
		var candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]
		candidates.shuffle()
		var region = n * 3
		for x in range(region, region + 3):
			for y in range(region, region + 3):
				numbers[x][y] = candidates.pop_front()

func _get_panels():
	var panel_instances = get_children()
	var i = 0
	for x in row:
		for y in col:
			panels[x][y] = panel_instances[i]
			i += 1


func _show_numbers():
	for x in row:
		for y in col:
			var label : Label = panels[x][y].get_node("Label")
			label.text = str(numbers[x][y])
			label.rect_size = Vector2(size, size)

func _get_row(current_row):
	var to_rtn = []
	for y in col:
		to_rtn.append(numbers[current_row][y])
	return to_rtn

func _get_col(current_col):
	var to_rtn = []
	for x in row:
		to_rtn.append(numbers[x][current_col])
	return to_rtn


func _get_region(current_x, current_y):
	var to_rtn = []
	var region_x = current_x / 3 * 3
	var region_y = current_y / 3 * 3
	for x in range(3):
		for y in range(3):
			to_rtn.append(numbers[region_x + x][region_y + y])
	return to_rtn
	
#	for x in row:
#		for y in col:
#			if x == current_x and y == current_y:
#				pass

func _create_multidim_array(rows, cols):
	var rtn := []
	for x in rows:
		rtn.append([0])
		for y in cols:
			rtn[x].append(0)
	return rtn
