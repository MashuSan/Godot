extends HBoxContainer

func set_name(name):
	$Name.text = name

func set_right_guess():
	$CheckBox.pressed = true

func reset_check_box():
	$CheckBox.pressed = false

func increase_score():
	$Score.text = str(int($Score.text) + 1)

func get_name():
	return $Name.text
