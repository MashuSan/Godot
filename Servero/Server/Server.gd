extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 3456
const MAX_PLAYERS = 32
var peer = NetworkedMultiplayerENet.new()

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	LogWorker.set_control($Panel/Log)
	start_server()

func start_server():
	LogWorker.PrintLog("Try to start the server.")
	var result = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	
	if result != OK:
		print("Failed creating the server.")
		LogWorker.PrintLog("Failed creating the server\n")
		return
	else:
		LogWorker.PrintLog("Created the server\n")
		
	
	get_tree().set_network_peer(peer)

func _player_connected(id):
	LogWorker.PrintLog(str(id) + " connected to server\n")
	ServerManager._players_connected.append(id)

func _player_disconnected(id):
	LogWorker.PrintLog(str(id) + " left the game.")
	ServerManager._players_connected.erase(id)
	if id in ServerManager._open_games:
		ServerManager.remove_game_from_game_list(id)
