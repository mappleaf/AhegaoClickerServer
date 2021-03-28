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
			
			#if main_interface.user_pairs.keys().has(token):
			if PlayerData.player_data.keys().has(main_interface.user_pairs[token]):
				CreatePlayerContainer(peer_id, false, main_interface.user_pairs[token], token)
			else:
				CreatePlayerContainer(peer_id, true, main_interface.user_pairs[token], token)
			
			awaiting_verification.erase(peer_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			yield(get_tree().create_timer(2), "timeout")
	main_interface.ReturnTokenVerificationResults(peer_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(peer_id)
		main_interface.network.disconnect_peer(peer_id)

func CreatePlayerContainer(id, is_new, username, token) -> void:
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(id)
	get_parent().add_child(new_player_container, true)
	var player_container = main_interface.get_node(str(id))
	FillPlayerContainer(player_container, is_new, username, token)
	main_interface.user_peers[username] = id

func FillPlayerContainer(player_container, is_new, username, token) -> void:
	if is_new:
		player_container.username = username
		player_container.token = token
		player_container.owned_units = ServerData.starting_data.owned_units
		player_container.units_in_room = ServerData.starting_data.units_in_room
		player_container.money = ServerData.starting_data.money
		player_container.gacha_starting = ServerData.starting_data.gacha_starting
		player_container.gacha_regular = ServerData.starting_data.gacha_regular
		player_container.gacha_special = ServerData.starting_data.gacha_special
		
		PlayerData.player_data[username] = {}
		PlayerData.player_data[username].owned_units = ServerData.starting_data.owned_units
		PlayerData.player_data[username].units_in_room = ServerData.starting_data.units_in_room
		PlayerData.player_data[username].money = ServerData.starting_data.money
		PlayerData.player_data[username].gacha_starting = ServerData.starting_data.gacha_starting
		PlayerData.player_data[username].gacha_regular = ServerData.starting_data.gacha_regular
		PlayerData.player_data[username].gacha_special = ServerData.starting_data.gacha_special
		PlayerData.save_player_data()
	elif username != null:
		player_container.username = username
		player_container.token = token
		player_container.owned_units = PlayerData.player_data[username].owned_units
		player_container.units_in_room = PlayerData.player_data[username].units_in_room
		player_container.money = PlayerData.player_data[username].money
		player_container.gacha_starting = PlayerData.player_data[username].gacha_starting
		player_container.gacha_regular = PlayerData.player_data[username].gacha_regular
		player_container.gacha_special = PlayerData.player_data[username].gacha_special


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
