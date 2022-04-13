extends Node

var left_box : CheckBox = null
var right_box : CheckBox = null
var random = RandomNumberGenerator.new()

var lines = [[], [], [], []]
var answers = []
var right_answers = {}
var score = 0

func _ready():
	if Player._is_host:
		GameManager.load_questions()
	
	$QuestionLoadTimer.set_wait_time(2)
	$QuestionLoadTimer.start()


func next_question():
	answers = GameManager.questions[GameManager.questions_array[GameManager.questionNumber]]
	GameManager.questionNumber += 1
	
	if left_box:
		left_box.pressed = false
	left_box = null
	
	if right_box:
		right_box.pressed = false
	right_box = null
	
	var show_answers_left = shuffle_children(answers[0])
	var show_answers_right = shuffle_children(answers[1])
	
	for i in range(4):
		$LeftSide.get_child(i).text = show_answers_left[i]
		$RightSide.get_child(i).text = show_answers_right[i]
		right_answers[answers[0][i]] = answers[1][i]


func shuffle_children(list):
	randomize()
	var shuffled = list.duplicate()
	shuffled.shuffle()
	
	return shuffled

func _on_CheckBox_pressed():
	if left_box != null:
		left_box.pressed = false
		left_box = null

	for item in $LeftSide.get_children():
		if item.get_child(0).pressed:
			left_box = item.get_child(0)
			break
	
	if left_box and right_box:
		draw_line()

func _on_CheckBox_pressed2():
	if right_box != null:
		right_box.pressed = false
		right_box = null

	for item in $RightSide.get_children():
		if item.get_child(0).pressed:
			right_box = item.get_child(0)
			break
	
	if left_box and right_box:
		draw_line()

func draw_line():
	var line = Line2D.new()
	add_child(line)

	var color = Color(random.randf_range(0, 1), random.randf_range(0, 1),random.randf_range(0, 1))
	
	line.set_default_color(color)

	line.add_point(Vector2(left_box.rect_global_position + left_box.rect_size / 2))
	line.add_point(Vector2(right_box.rect_global_position + right_box.rect_size / 2))
	line.update()
	
	var pos = int(left_box.name.split(' ')[1])

	if lines[pos] != null and lines[pos]:
		lines[pos][0].queue_free()
		
	var answer_arr = [line, pos, [left_box.get_parent(), right_box.get_parent()]]

	lines[pos] = answer_arr
	
	left_box.pressed = false
	left_box = null
	right_box.pressed = false
	right_box = null


remote func exit_game():
	get_tree().change_scene("res://Game/ScoreInfo.tscn")


func _on_SubmitButton_pressed():
	if $SubmitButton.text == "EXIT" and Player._is_host:
		for player_info in ServerManager._player_in_same_game_room_list:
			if player_info[0] != Player._player_id:
				rpc_id(player_info[0], "exit_game")
		
		exit_game()

	var wrong_answer = false
	for line in lines:
		if line == []:
			wrong_answer = true
			break

		if right_answers[line[2][0].text] == line[2][1].text:
			continue
		
		else:
			wrong_answer = true
			break
	
	if not wrong_answer:
		score += 1
	
	if GameManager.is_last_question():
		if not Player._is_host:
			$SubmitButton.visible = false
		else:
			$SubmitButton.text = "EXIT"
		GameManager.call_adding(score)

		return
	
	for line in lines:
		if len(line) > 0:
			line[0].queue_free()
	
	lines = [[], [], [], []]
	
	next_question()


func _on_QuestionLoadTimer_timeout():
	if GameManager.questions_loaded:
		# $Game/QuestionNumberLabel.text =  "1/" + str(GameManager.get_questions_size())
		next_question()
		$Introduction.visible = false
		$QuestionLoadTimer.stop()
