extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 4095


func _ready() -> void:
	StartServer()
	print(str(ServerData.units_list))


func StartServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

remote func send_units_list() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var data = ServerData.units_list
	rpc_id(peer_id, "_return_units_list", data)
	print("Sending " + str(data) + " to peer id " + str(peer_id))


func _peer_connected(id) -> void:
	print("Peer id " + str(id) + " connected")

func _peer_disconnected(id) -> void:
	print("Peer id " + str(id) + " disconnected")
