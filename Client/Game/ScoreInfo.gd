extends Control


func _ready():
	load_winners()


func load_winners():
	var winners = GameManager.get_score_board()
	
	winners.sort_custom(self, "custom_comparison")
	
	var size = len(winners)
	
	$Winner.text += str(winners[0][0]) + " with score " + str(winners[0][1])
	
	if size > 1:
		$Winner2.text += str(winners[1][0]) + " with score " + str(winners[1][1])
	
	if size > 2:
		$Winner3.text += str(winners[2][0]) + " with score " + str(winners[2][1])


func custom_comparison(a, b):
	return a[1] > b[1]


func _on_Button_pressed():
	GameManager.set_script(null)
	GameManager.set_script(preload("res://Game/GameManager.gd"))
	# self.queue_free()
	get_tree().change_scene("res://GameRoom/GameRoom.tscn")
	"""
	Player.reset_player()
	ServerManager.left_game()

	if Player._is_host:
		ServerManager.close_game()
	
	ServerManager.send_open_games_request_to_server()
	get_tree().change_scene("res://GameData/Lobby.tscn")
	"""
