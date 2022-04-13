extends Node

func path(game_mode):
	return "./Sets/" + game_mode + "Questions/"

func get_files(game_mode):
	var files = []
	var dir = Directory.new()
	dir.open(path(game_mode))
	dir.list_dir_begin(true)

	var file = dir.get_next()
	while file != '':
		if file.find(".xml") > 0:
			files += [file]

		file = dir.get_next()
	
	return files

func save_questions(set_name, game_mode, questions):
	var save_game = File.new()
	
	save_game.open(path(game_mode) + set_name, File.WRITE)
	
	match game_mode:
		"Quizz", "WordPairing":
			save_game.store_line(to_json(questions))

		"CodePuzzle":
			for q in questions:
				var counter = 0
				save_game.store_line(to_json(questions))
			
				for answers in questions[q]:
					for bytes in answers:					
						var new_image = Image.new()
						new_image.load_png_from_buffer(bytes)
						new_image.save_png(path(game_mode) + "_" + set_name.split(".")[0] + str(q) + str(counter) + ".png")
						
						counter += 1
	
	save_game.close()

func load_questions(game_mode, file_name):
	var questions
	var file_path = path(game_mode) + file_name + ".xml"
	var save_game = File.new()

	if not save_game.file_exists(file_path):
		return #

	save_game.open(file_path, File.READ)

	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		questions = parse_json(save_game.get_line())

	save_game.close()
	
	return questions

func load_images(game_mode, file_name):
	var questions
	var file_path = path(game_mode) + file_name + ".xml"
	var save_game = File.new()

	if not save_game.file_exists(file_path):
		return #

	save_game.open(file_path, File.READ)

	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		questions = parse_json(save_game.get_line())
	
	for q_number in questions:
		var counter = 0
		var image_array = []
		for images in questions[q_number]:
			for image in images:
				var image_from_file: = File.new()
				image_from_file.open(path(game_mode) + "_" + file_name + str(q_number) + str(counter) + ".png", File.READ)
				image_array.append(image_from_file.get_buffer(image_from_file.get_len()))
				counter += 1
		questions[q_number] = image_array
	
	save_game.close()
	
	return questions
	

func get_questions(game_mode, file_name):
	match game_mode:
		"Quizz", "WordPairing":
			return load_questions(game_mode, file_name)
		"CodePuzzle":
			return load_images(game_mode, file_name)

