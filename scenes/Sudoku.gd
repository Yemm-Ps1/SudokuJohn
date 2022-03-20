extends Control

var PanelScene = preload("res://scenes/Panel.tscn")

var row = 9
var col = 9

var size = 50

var offset = 3

var numbers = _create_multidim_array(row, col)
var panels = _create_multidim_array(row, col)

var valid_numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]

var sudoku_seed = 1



func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		if int(key_typed) in valid_numbers:
			if selected_panel:
				selected_panel.set_label_text(key_typed)
		if key_typed == " " or typed_event.scancode == KEY_BACKSPACE or typed_event.scancode == KEY_DELETE:
			if selected_panel:
				selected_panel.set_label_text(" ")
		_update_numbers()

func _update_numbers():
	for x in row:
		for y in col:
			numbers[x][y] = panels[x][y].get_label()

func initialize_game(seedo):
	for n in get_children():
		remove_child(n)
	seed(seedo)
	_init_grid()
	_init_numbers()
	_clean_numbers()
	_init_panels()

func _ready():
	initialize_game(sudoku_seed)

func _get_single_candidate():
	pass

func check_errors():
	var duped = false
	for x in row:
		for y in col:
			if !panels[x][y].unselectable:
				if(_check_duplicate(_get_row(x))):
#					print("DUPLICATE ON ROW: ", x)
					duped = true
				if(_check_duplicate(_get_col(y))):
#					print("DUPLICATE ON COL: ", y)
					duped = true
				if(_check_duplicate(_get_region(x, y))):
#					print("DUPLICATE IN REGION:", x, y)
					duped = true
				if duped:
					return true
	return false


func _check_duplicate(arr):
	for i in range(arr.size()):
		for j in range(arr.size()):
			if !arr[i] == null and !arr[j] == null:
				if arr[j] == arr[i] && i != j:
					return true



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


func _init_numbers():
	for n in 3:
		var candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]
		candidates.shuffle()
		var region = n * 3
		for x in range(region, region + 3):
			for y in range(region, region + 3):
				numbers[x][y] = candidates.pop_front()
	_fill_empty()

func _clean_numbers():
	for x in row:
		for y in col:
			var candidates = _get_candidates(x, y)
			if candidates.empty():
				numbers[x][y] = null

func _get_empty():
	for x in row:
		for y in col:
			if numbers[x][y] == null:
				return [x, y]
	return [null, null]


func _fill_empty():
	var x = _get_empty()[0]
	var y = _get_empty()[1]
	if !x and !y:
		return true
	
	var candidates = _get_candidates(x, y)
	
	if !candidates:
		return false
		
	while candidates:
		numbers[x][y] = candidates.pop_back()
		if _fill_empty():
			return true
		else:
			numbers[x][y] = null


func _init_panels():
	var panel_instances = get_children()
	var i = 0
	for x in row:
		for y in col:
			var panel = panel_instances[i]
			panel.connect("selected", self, "_on_Panel_selected")
			var label = panel.get_node("Label")
			label.text = str(numbers[x][y]) if numbers[x][y] else ""
			label.rect_size = Vector2(size, size)
			if numbers[x][y] != null:
				panel.unselectable()
			panels[x][y] = panel
			i += 1

var selected_panel

func _on_Panel_selected(panel):
	if panel.unselectable:
			return
	if selected_panel:
		selected_panel.deselected()
	selected_panel = panel
	selected_panel.selected()
	print("Panel Selected")

func _get_candidates(x, y):
	var candidates = valid_numbers
	candidates = compare_array(candidates, _get_row(x))
	candidates = compare_array(candidates, _get_region(x, y))
	candidates = compare_array(candidates, _get_col(y))
	return candidates

func _get_candidates2(x, y):
	var candidates = valid_numbers
	for i in _get_row(x):
		candidates.erase(i)
	for i in _get_col(y):
		candidates.erase(y)
	for i in _get_region(x, y):
		candidates.erase(i)
	return candidates


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
		rtn.append([null])
		for y in cols:
			rtn[x].append(null)
	return rtn


func compare_array(arr1, arr2):
	var to_rtn = []
	for i in arr1:
		if !i in arr2:
			to_rtn.append(i)
	return to_rtn
