extends Node


onready var main_interface = get_parent()
onready var player_container_scene = preload("res://src/scenes/PlayerContainer.tscn")

var awaiting_verification = {}


func start(id) -> void:
	awaiting_verification[id] = {"Timestamp": OS.get_unix_time()}
	main_interface.FetchToken(id)

func Verify(peer_id, token) -> void:
	var token_verification = false
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			CreatePlayerContainer(peer_id)
			awaiting_verification.erase(peer_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			yield(get_tree().create_timer(2), "timeout")
	main_interface.ReturnTokenVerificationResults(peer_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(peer_id)
		main_interface.network.disconnect_peer(peer_id)

func CreatePlayerContainer(id) -> void:
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(id))
	FillPlayerContainer(player_container)

func FillPlayerContainer(player_container) -> void:
	player_container.owned_units = ServerData.test_data.owned_units
	player_container.units_in_room = ServerData.test_data.units_in_room


func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key, false)
					main_interface.network.disconnect_peer(key)
