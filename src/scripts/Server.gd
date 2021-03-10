extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 4095

onready var playerVerification = $PlayerVerification


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


func _peer_connected(id) -> void:
	print("Peer id " + str(id) + " connected")
	playerVerification.start(id)

func _peer_disconnected(id) -> void:
	print("Peer id " + str(id) + " disconnected")
	get_node(str(id)).queue_free()
