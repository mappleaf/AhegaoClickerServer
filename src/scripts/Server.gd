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

remote func FetchServerTime(client_time) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)

remote func DetermineLatency(client_time) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "ReturnLatency", client_time)


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

func add_unit(username, key) -> void:
	var peer_id = user_peers[username]
	var container = get_node(str(peer_id))
	
	if !container.owned_units.keys().has(key):
		container.owned_units[key] = ServerData.units_list[key]
	else:
		container.stardust += 100
		PlayerData.player_data[username].stardust += 100
	
	var units = container.owned_units
	rpc_id(peer_id, "_return_owned_units", units)

remote func sync_enemy_health(value) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var container = get_node(str(peer_id))
	container.enemy.health = value
	PlayerData.player_data[container.username].enemy.health = value

remote func get_user_money() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var count = get_node(str(peer_id)).money
	rpc_id(peer_id, "_return_money_count", count)

remote func get_user_stardust() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var count = get_node(str(peer_id)).stardust
	rpc_id(peer_id, "_return_stardust", count)

func send_user_stardust(peer_id) -> void:
	var count = get_node(str(peer_id)).stardust
	rpc_id(peer_id, "_return_stardust", count)

remote func send_enemies_list() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var data = ServerData.enemies
	rpc_id(peer_id, "_return_enemies_list", data)

remote func send_current_enemy() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var enemy = get_node(str(peer_id)).enemy
	rpc_id(peer_id, "_return_current_enemy", enemy, false)

remote func killed_enemy() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var container = get_node(str(peer_id))
	
	var min_money = container.enemy.min_money
	var max_money = container.enemy.max_money
	
	var money_for_kill = randi() % int(max_money) + int(min_money)
	#var enemy_level = max(randi() % (int(container.level) + 5) + (int(container.level) - 5), 1)
	var enemy_level = max(int(rand_range(container.level + 5, container.level - 5)), 1)
	
	PlayerData.player_data[container.username].money += money_for_kill
	container.money += money_for_kill
	send_user_money(peer_id)
	send_new_enemy(peer_id, enemy_level)

remote func get_user_gacha() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var container = get_node(str(peer_id))
	
	var gacha_array = [container.gacha_starting, container.gacha_regular, container.gacha_special]
	
	rpc_id(peer_id, "_return_gacha", gacha_array)

remote func open_gacha(gacha_type) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var container = get_node(str(peer_id))
	
	match gacha_type:
		"gacha_starting":
			pass
		"gacha_regular":
			pass
		"gacha_special":
			if container.gacha_special >= 1:
				container.gacha_special -= 1
				var d = randf()
				
				#TESTING!!!
				#while d < 0.7:
				#	d = randf()
				
				if d < 0.7:
					add_weapon(peer_id, GenerateWeapon())
				elif d < 0.94:
					var drops = ServerData.gachas.special.star4.duplicate()
					drops.shuffle()
					var drop_key = drops.pop_front()
					add_unit(container.username, drop_key)
				else:
					var drops = ServerData.gachas.special.star5.duplicate()
					drops.shuffle()
					var drop_key = drops.pop_front()
					add_unit(container.username, drop_key)
			else:
				print(str("Not enough special gacha on user ", peer_id))

func add_weapon(peer_id, weapon) -> void:
	var container = get_node(str(peer_id))
	
	PlayerData.player_data[container.username].weapons.append(weapon)
	container.weapons.append(weapon)
	
	send_user_weapons(peer_id)

func GenerateWeapon() -> Dictionary:
	var new_weapon = {}
	new_weapon["id"] = WeaponDetermineType()
	new_weapon["rarity"] = WeaponDetermineRarity()
	
	var is_enchanted = randf()
	if is_enchanted <= 0.1:
		new_weapon["enchant"] = WeaponDetermineEnchantment()
	else:
		new_weapon["enchant"] = null
	
	for i in ServerData.weapon_stats:
		if ServerData.weapons_list[new_weapon["id"]][i] != null:
			new_weapon[i] = WeaponDetermineStats(new_weapon["id"], new_weapon["rarity"], i)
	
	return new_weapon

func WeaponDetermineType() -> String:
	var new_weapon_id
	var weapon_ids = ServerData.weapons_list.keys()
	new_weapon_id = weapon_ids[randi() % weapon_ids.size()]
	return new_weapon_id

func WeaponDetermineRarity() -> String:
	var new_weapon_rarity
	var rarities = ServerData.weapon_rarity_distribution.keys()
	
	var rarity_roll = randi() % 100 + 1
	for i in rarities:
		if rarity_roll <= ServerData.weapon_rarity_distribution[i]:
			new_weapon_rarity = i
			break
		else:
			rarity_roll -= ServerData.weapon_rarity_distribution[i]
	
	return new_weapon_rarity

func WeaponDetermineEnchantment():
	return null

func WeaponDetermineStats(id, rarity, stat):
	var stat_value
	if ServerData.weapon_scaling_stats.has(stat):
		stat_value = int(ServerData.weapons_list[id][stat]) * ServerData.weapons_list[id][rarity + "Multi"]
	else:
		stat_value = ServerData.weapons_list[id][stat]
	return stat_value


remote func get_user_weapons() -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	var weapons = get_node(str(peer_id)).weapons
	rpc_id(peer_id, "_return_weapons", weapons)

func send_user_weapons(peer_id) -> void:
	var weapons = get_node(str(peer_id)).weapons
	rpc_id(peer_id, "_return_weapons", weapons)

func send_user_money(peer_id) -> void:
	var count = get_node(str(peer_id)).money
	rpc_id(peer_id, "_return_money_count", count)

func send_new_enemy(peer_id, enemy_level) -> void:
	var container = get_node(str(peer_id))
	
	var temp_enemies = ServerData.enemies.duplicate()
	var enemy_keys = temp_enemies.keys()
	enemy_keys.shuffle()
	var enemy_key = enemy_keys.pop_front()
	
	var enemy = temp_enemies[enemy_key].duplicate()
	enemy.max_health = int(enemy.max_health * (enemy_level * enemy.health_factor))
	enemy.health = enemy.max_health
	
	PlayerData.player_data[container.username].enemy = enemy
	container.enemy = enemy
	
	rpc_id(peer_id, "_return_current_enemy", enemy, true)

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
