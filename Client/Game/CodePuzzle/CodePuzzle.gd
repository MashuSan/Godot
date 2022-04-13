extends Node2D

var images_pool = []
var code_images_pool = []
var score = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# $Game/FileDialog.popup()
	if Player._is_host:
		GameManager.load_questions()

	$QuestionLoadTimer.set_wait_time(2)
	$QuestionLoadTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func next_question():
	images_pool = GameManager.questions[GameManager.questions_array[GameManager.questionNumber]]
	GameManager.questionNumber += 1
	GameManager.code_images = []
	
	$Game/QuestionNumberLabel.text[0] = str(GameManager.questionNumber)
	
	for img in images_pool:
		var code_image = load("res://Game/CodePuzzle/CodeImage.tscn").instance()
		
		GameManager.texture_buttons.append(code_image)
		code_images_pool.append(code_image)

		var created_texture = get_image_remote(img)
		GameManager.code_images.append(created_texture)
		$SideImages/OptionButton.add_icon_item(created_texture, "")
		
		code_images_pool[-1].texture_normal = created_texture
	
	code_images_pool = shuffle_children(code_images_pool)
	
	var button_pos = 0
	for image in code_images_pool:
		$Game/VBoxContainer.add_child(image)
		image.button_pos = button_pos
		button_pos += 1


func _unhandled_input(event):
	# $Camera2D._unhandled_input(event)
	pass

func shuffle_children(list):
	randomize()
	var shuffled = list.duplicate()
	shuffled.shuffle()
	
	return shuffled
	
remote func get_image_remote(bytes):
	
	var new_image = Image.new()
	new_image.load_png_from_buffer(bytes)
	var itex = ImageTexture.new()
	
	itex.create_from_image(new_image)
	
	return itex

func send(bytes):
	# get_image_remote(bytes)
	for player_info in ServerManager._player_in_same_game_room_list:
		if player_info[0] != Player._player_id:
			rpc_id(player_info[0], "get_image_remote", bytes)

remote func exit_game():
	get_tree().change_scene("res://Game/ScoreInfo.tscn")

func _on_Button_pressed():
	if $Submit.text == "EXIT" and Player._is_host:
		for player_info in ServerManager._player_in_same_game_room_list:
			if player_info[0] != Player._player_id:
				rpc_id(player_info[0], "exit_game")
		
		exit_game()
		
	var counter = 0
	var wrong_answer = false

	for item in $Game/VBoxContainer.get_children():
		var texture = item.texture_normal
		var a = GameManager.code_images
		if texture != GameManager.code_images[counter]:
			wrong_answer = true
			break
		
		counter += 1
		
	if not wrong_answer:
		score += 1
	
	for child in $Game/VBoxContainer.get_children():
		child.queue_free()
		code_images_pool.pop_back()
	
	if GameManager.is_last_question():
		if not Player._is_host:
			$Submit.visible = false
		else:
			$Submit.text = "EXIT"
		GameManager.call_adding(score)

		return

	next_question()


func _on_QuestionLoadTimer_timeout():
	if GameManager.questions_loaded:
		$Game/QuestionNumberLabel.text =  "1/" + str(GameManager.get_questions_size())
		$Game.visible = true
		$SideImages.visible = true
		next_question()
		$QuestionLoadTimer.stop()


func _on_OptionButton_item_selected(index):
	GameManager.code_images_position = index
