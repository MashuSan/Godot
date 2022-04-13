extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var option_button = get_node("PanelAnswers/OptionButton")
var questions = {}
var image_byte_set = []
var position = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_texture(bytes):
	var new_image = Image.new()
	new_image.load_png_from_buffer(bytes)
	var itex = ImageTexture.new()
	
	itex.create_from_image(new_image)

	return itex

func _on_FileDialog_files_selected(paths):
	for path in paths:
		var img = Image.new()
		img.load(path)
		
		var bytes = img.save_png_to_buffer()
		
		var texture = create_texture(bytes)
		
		image_byte_set.append(bytes)
		print(len(bytes))
		option_button.add_icon_item(texture, "image" + str(option_button.get_item_count() + 1))
	# get_image_remote(bytes)
	
	#get_image_remote(raw_data)
	# Thread.new().start(self, "send", bytes)

func reset_text():
	option_button.clear()
	$AddSetText.text = ""


func _on_Button_pressed():
	$PanelAnswers/FileDialog.popup()


func _on_Button2_pressed():
	image_byte_set.remove(option_button.get_selected_id())
	option_button.remove_item(option_button.get_selected_id())
	option_button.select(0)
	option_button.update()


func _on_AddQuestionButton_pressed():
	if (len(image_byte_set) > 10):
		OS.alert("Too many images, maximum is 10", "Message Title")
		return
	questions[position] = [image_byte_set]
	position += 1
	image_byte_set = []
	reset_text()

func _on_ExitButton_pressed():
	self.queue_free()


func _on_AddSetButton_pressed():
	ServerManager.save_game_questions($AddSetText.text + ".xml", ServerManager.game_modes[2], questions)
	self.queue_free()
