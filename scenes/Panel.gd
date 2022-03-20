extends Panel

signal selected

var style = StyleBoxFlat.new()

var default_color = Color.white
var selected_color = Color.gray
var unselectable_color = Color.yellow

var unselectable = false

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
		
