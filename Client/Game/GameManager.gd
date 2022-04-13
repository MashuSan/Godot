extends Node

var questions = {}

var questions_array = []

var right_answers = []

var questionNumber = 0

var score_board = []

var code_images_position = 0

var code_images = []

var texture_buttons = []

var guess_word = ""

var already_added_score = false

var questions_loaded = false

var game_mode

func load_questions():
	load_questions_clients(ServerManager.get_questions())

	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "load_questions_clients", questions)

func call_adding(score):
	if already_added_score:
		return

	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "add_to_board", Player._player_name, score)
	
	add_to_board(Player._player_name, score)
	already_added_score = true

func everyone_submitted():
	return len(score_board) == len(ServerManager._open_games[Player._game_id][3])

remote func add_to_board(name, score):
	score_board.append([name, score])


func change_code_texture(button_pos, texture_pos):
	for player_id in ServerManager._player_in_same_team[Player._team]:
		if Player._player_id != player_id:
			rpc_id(player_id, "change_code_texture_remote", button_pos, texture_pos)

remote func change_code_texture_remote(button_pos, texture_pos):
	texture_buttons[button_pos].change_texture(texture_pos)

remote func load_questions_clients(qs):
	questions = qs
	questions_array = qs.keys()

	for q in questions:
		match game_mode:
			"CodePuzzle", "WordPairing":
				right_answers = range(1, len(questions[q]) + 1)
			"Quizz":
				right_answers.append(questions[q][1])
	
	questions_loaded = true


func get_code_texture(position):
	return code_images[position]


func set_word_guess(text):	
	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "set_word_guess_peer", text)
	
	set_word_guess_peer(text)

remote func set_word_guess_peer(text):
	guess_word = text


"""
func set_questions(qs):
	questions = qs
	questions_array = questions.keys()
	
	for q in questions:
		right_answers.append(questions[q][1])
"""

func get_answers(index):
	return questions[questions_array[index]][0]

func get_answer(qindex, qanswer):
	return questions[questions_array[qindex]][0][qanswer - 1]

func get_question(index):
	var q = questions_array[index]
	questionNumber += 1
	
	return q

func is_last_question():
	return questionNumber >= get_questions_size()

func get_score_board():
	return score_board

func get_questions():
	return questions_array

func get_questions_size():
	return len(questions_array)

func get_question_number():
	return questionNumber

func get_right_answer():
	return right_answers[questionNumber - 1]
