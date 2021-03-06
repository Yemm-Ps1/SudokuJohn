extends CanvasLayer


onready var sudoku := $HSplitContainer/HBoxContainer3/Sudoku

var check_rect

var screen_size = Vector2(0,0)


func _ready():
	screen_size.x = get_viewport().get_visible_rect().size.x
	screen_size.y = get_viewport().get_visible_rect().size.y
	check_rect = ColorRect.new()
	add_child(check_rect)
	check_rect.rect_size = screen_size
	check_rect.visible = false

var time_elapsed = 0.0
func _process(delta):
	_rect_fade()
	if !sudoku.solved:
		time_elapsed += delta
	$HSplitContainer/TimerLabel.text = str("%.1f" % stepify(time_elapsed, 0.1), " Seconds")


func _on_NewGame_pressed():
	var new_seed = randi()
	time_elapsed = 0.0
	sudoku.initialize_game(new_seed)


func _on_Check_pressed():
	if(sudoku.check_errors()):
		rect_set(Color.red)
	else:
		rect_set(Color.green)

func rect_set(color : Color):
	check_rect.color = color
	check_rect.visible = true

func _rect_fade():
	if check_rect.color.a > 0 and check_rect.visible:
		check_rect.color.a -= 0.02
	else:
		check_rect.color.a = 1
		check_rect.visible = false

func _on_Hint_pressed():
	sudoku.solve_single_candidate()




func _on_Solve_pressed():
	sudoku.solve()


func _on_Mark_pressed():
	sudoku.mark()
