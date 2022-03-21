extends Panel

signal selected

var style = StyleBoxFlat.new()

var default_color = Color.white
var selected_color = Color.gray
var unselectable_color = Color.yellow

var unselectable = false

onready var grid_container = $GridContainer

func _ready():
	add_stylebox_override("panel", style)
	deselected()
	set_process(true)

func get_label():
	if int($Label.text) in [1, 2, 3, 4, 5, 6, 7, 8, 9]:
		return int($Label.text)
	return null
	
func set_label_text(text : String):
	$Label.text = text

func selected():
	style.set_bg_color(selected_color)
	update()

func deselected():
	style.set_bg_color(default_color)
	update()

func unselectable():
	unselectable = true
	style.set_bg_color(unselectable_color)
	update()

func _on_Panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("selected", self)

func init_hint_labels(size):
	var labels = grid_container.get_children()
	grid_container.rect_size = size
	for i in labels:
		i.rect_min_size = size - Vector2(30, 32)


func set_hint_labels(array : Array):
	var labels = grid_container.get_children()
	for i in labels:
		if i is Label:
			i.text = str(array.pop_front())
			if i.text == "Null":
				i.text = ""

func add_hint_label(number):
	var labels = grid_container.get_children()
	for i in labels:
		if i is Label:
			if i.text == str(number):
				i.text = ""
				sort_hint_labels()
				return
	for i in labels:
		if i is Label:
			if i.text == "":
				i.text = str(number)
				sort_hint_labels()
				return
	

func sort_hint_labels():
	var current_label_values = get_hint_labels()
	current_label_values.sort()
	set_hint_labels(current_label_values)
				

func get_hint_labels():
	var labels = grid_container.get_children()
	var to_rtn = []
	for i in labels:
		if i is Label:
			if i.text:
				to_rtn.append(int(i.text))
	return to_rtn

func remove_hint_labels(array : Array):
	var labels = grid_container.get_children()
	for i in labels:
		if i is Label:
			if int(i.text) in array:
				i.text = ""
				
