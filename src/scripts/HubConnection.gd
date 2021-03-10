extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912

onready var gameserver = get_node("/root/Server")


func _ready() -> void:
	ConnectToServer()

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if !custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func ConnectToServer() -> void:
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("server_disconnected", self, "_on_server_disconnected")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

remote func RecieveLoginToken(token) -> void:
	gameserver.expected_tokens.append(token)


func _on_server_disconnected() -> void:
	print("Server is shut down")
	get_tree().quit()

func _on_connection_failed() -> void:
	print("Failed to connect to GameServer hub")

func _on_connection_succeeded() -> void:
	print("Succesfully connected to GameServer hub")
