extends Button

var _game_name
var _max_players
var _game_id

func set_game_id(game_id):
	_game_id = game_id

func set_game_name(game_name):
	_game_name = game_name

func set_max_players(max_players):
	_max_players = max_players

func update_gui():
	$HBoxContainer/Game_name.text = _game_name
	$HBoxContainer/Number_of_player.text = str(len(ServerManager._open_games[_game_id][3])) + "/" + str(_max_players)

func _on_Games_entry_pressed():
	ServerManager.send_open_games_request_to_server()
	yield(ServerManager, "updated_games")
	if _game_id in ServerManager._open_games and !is_full():
		ServerManager.join_game(_game_id)

func is_full():
	var number_of_players = len(ServerManager._open_games[_game_id][3])
	return number_of_players >= _max_players
