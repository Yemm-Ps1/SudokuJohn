extends Control

var PanelScene = preload("res://scenes/Panel.tscn")

var row = 9
var col = 9

var size = 50

var offset = 3

var numbers = _create_multidim_array(row, col-1)
var panels = _create_multidim_array(row, col-1)

var valid_numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]

var modifiers = ["!", "\"", "£", "$", "%", "^", "&", "*", "("]

var sudoku_seed = 1

var solved = false

func _check_solved():
	if numbers == solved_numbers:
		solved = true
		return true
	return false

var shifted = false
func _unhandled_input(event):
	if event is InputEventKey:
		var typed_event = event as InputEventKey
		var key_typed
		if typed_event.unicode == 163:
			key_typed = "3"
		else:
			key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if typed_event.is_action_pressed("shift"):
			print("SHIFTED")
			shifted = true
		elif typed_event.is_action_released("shift"):
			print("UNSHIFTED")
			shifted = false
		if event.is_pressed():
			if key_typed in modifiers:
				key_typed = str(valid_numbers[modifiers.find(key_typed)])
			if int(key_typed) in valid_numbers:
				if selected_panel:
					if shifted:
						selected_panel.add_hint_label(key_typed)
					else:
						selected_panel.set_label_text(key_typed)
			if key_typed == " " or typed_event.scancode == KEY_BACKSPACE or typed_event.scancode == KEY_DELETE:
				if selected_panel:
					selected_panel.set_label_text(" ")
			_update_numbers()
			remove_redundant_marks()

func _update_numbers():
	for x in row:
		for y in col:
			numbers[x][y] = panels[x][y].get_label()
	_init_panels()

var solved_numbers = []
func initialize_game(seedo):
	solved = false
	for n in get_children():
		remove_child(n)
	seed(seedo)
	_init_grid()
	_init_numbers()
	solved_numbers = numbers.duplicate(true)
	_clean_numbers()

	_init_panels()


func _ready():
	initialize_game(sudoku_seed)
	
func solve_single_candidate():
	for x in row:
		for y in col:
			if numbers[x][y] == null:
				var candidates = _get_candidates(x, y)
				if candidates.size() == 1:
					numbers[x][y] = candidates[0]
					_init_panels()
					return



func solve():
	#numbers = solved_numbers
	_fill_empty()
	_init_panels()

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

func mark():
	for x in row:
		for y in col:
			if !numbers[x][y]:
				panels[x][y].set_hint_labels(_get_candidates(x, y))
			else:
				panels[x][y].set_hint_labels([])

func remove_redundant_marks():
	for x in row:
		for y in col:
			var marks = panels[x][y].get_hint_labels()
			var redundant = compare_array(marks, _get_candidates(x, y))
			if redundant:
				panels[x][y].remove_hint_labels(redundant)

func _clear_numbers():
	for x in row:
		for y in col:
			numbers[x][y] = null

func _init_numbers():
	_clear_numbers()
	for n in 3:
		var candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]
		candidates.shuffle()
		var region = n * 3
		for x in range(region, region + 3):
			for y in range(region, region + 3):
				numbers[x][y] = candidates.pop_front()
	_fill_empty()

var base_puzzle = []

func _clean_numbers():
	for x in row:
		for y in col:
			var candidates = _get_candidates(x, y)
			if candidates.empty():
				numbers[x][y] = null
	base_puzzle = numbers.duplicate(true)


func _get_empty():
	for x in row:
		for y in col:
			if numbers[x][y] == null:
				return [x, y]
	return [null, null]


func _fill_empty():
	var empty = _get_empty()
	var x = empty[0]
	var y = empty[1]
	if x == null and y == null:
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
			panel.init_hint_labels(Vector2(size, size))
			var label = panel.get_node("Label")
			label.text = str(numbers[x][y]) if numbers[x][y] else ""
			label.rect_size = Vector2(size, size)
			if numbers[x][y] == base_puzzle[x][y] and numbers[x][y] != null:
				panel.unselectable()
			panels[x][y] = panel
			i += 1
	remove_redundant_marks()
	_check_solved()
		

var selected_panel

func _on_Panel_selected(panel):
	if panel.unselectable:
			return
	if selected_panel:
		selected_panel.deselected()
	selected_panel = panel
	selected_panel.selected()


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
