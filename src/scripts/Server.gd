extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 4095

var expected_tokens = []
var user_pairs = {}
var user_peers = {}

onready var playerVerification = $PlayerVerification


func _ready() -> void:
	randomize()
	StartServer()
	print(str(ServerData.units_list))


func StartServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func FetchToken(peer_id) -> void:
	rpc_id(peer_id, "FetchToken")

remote func ReturnToken(token) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	playerVerification.Verify(peer_id, token)

func ReturnTokenVerificationResults(peer_id, result) -> void:
	rpc_id(peer_id, "ReturnTokenVerificationResults", result)


remote func send_units_list() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var data = ServerData.units_list
	rpc_id(peer_id, "_return_units_list", data)

remote func send_owned_units() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var units = get_node(str(peer_id)).owned_units
	rpc_id(peer_id, "_return_owned_units", units)

remote func send_units_in_room() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var units = get_node(str(peer_id)).units_in_room
	rpc_id(peer_id, "_return_units_in_room", units)

remote func get_units_in_room(list) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	get_node(str(peer_id)).units_in_room = list

remote func add_random_unit() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var unit_type_index = randi() % ServerData.units_list.keys().size()
	var unit_type = ServerData.units_list.keys()[unit_type_index]
	
	if !get_node(str(peer_id)).owned_units.keys().has(unit_type):
		get_node(str(peer_id)).owned_units[unit_type] = ServerData.units_list[unit_type]
	else:
		pass
	
	var units = get_node(str(peer_id)).owned_units
	rpc_id(peer_id, "_return_owned_units", units)

remote func get_user_money() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var count = get_node(str(peer_id)).money
	rpc_id(peer_id, "_return_money_count", count)

func send_user_money(peer_id) -> void:
	var count = get_node(str(peer_id)).money
	rpc_id(peer_id, "_return_money_count", count)

func RemovePlayerContainer(peer_id) -> void:
	var container = get_node(str(peer_id))
	var token = container.token
	user_pairs.erase(token)
	container.queue_free()


func _peer_connected(id) -> void:
	print("Peer id " + str(id) + " connected")
	playerVerification.start(id)

func _peer_disconnected(id) -> void:
	print("Peer id " + str(id) + " disconnected")
	RemovePlayerContainer(id)


func _on_TokenExpiration_timeout() -> void:
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
